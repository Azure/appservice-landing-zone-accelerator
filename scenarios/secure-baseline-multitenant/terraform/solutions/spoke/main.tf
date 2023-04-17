resource "random_password" "vm_admin_username" {
  length  = 10
  special = false
}

resource "random_password" "vm_admin_password" {
  length  = 16
  special = true
}

data "azuread_client_config" "current" {}

locals {
  tenant_id         = var.tenant_id == null ? data.azuread_client_config.current.tenant_id : var.tenant_id
  vm_admin_username = var.vm_admin_username == null ? random_password.vm_admin_username.result : var.vm_admin_username
  vm_admin_password = var.vm_admin_password == null ? random_password.vm_admin_password.result : var.vm_admin_password
}

locals {
  spoke_vnet_cidr          = var.spoke_vnet_cidr == null ? ["10.240.0.0/20"] : var.spoke_vnet_cidr
  appsvc_subnet_cidr       = var.appsvc_subnet_cidr == null ? ["10.240.0.0/26"] : var.appsvc_subnet_cidr
  front_door_subnet_cidr   = var.front_door_subnet_cidr == null ? ["10.240.0.64/26"] : var.front_door_subnet_cidr
  devops_subnet_cidr       = var.devops_subnet_cidr == null ? ["10.240.10.128/26"] : var.devops_subnet_cidr
  private_link_subnet_cidr = var.private_link_subnet_cidr == null ? ["10.240.11.0/24"] : var.private_link_subnet_cidr
}

resource "azurecaf_name" "resource_group" {
  name          = "spoke-${var.application_name}"
  resource_type = "azurerm_resource_group"
  suffixes      = [var.environment, var.location_short]
}

resource "azurerm_resource_group" "spoke" {
  name     = azurecaf_name.resource_group.result
  location = var.location

  tags = {
    "terraform"        = "true"
    "environment"      = var.environment
    "application-name" = var.application_name
  }
}

resource "azurecaf_name" "reader_identity" {
  name          = "spoke-${var.application_name}-reader"
  resource_type = "azurerm_user_assigned_identity"
}

resource "azurerm_user_assigned_identity" "reader" {
  location            = azurerm_resource_group.spoke.location
  name                = azurecaf_name.reader_identity.result
  resource_group_name = azurerm_resource_group.spoke.name
}

resource "azurecaf_name" "contributor_identity" {
  name          = "spoke-${var.application_name}-contributor"
  resource_type = "azurerm_user_assigned_identity"
}

resource "azurerm_user_assigned_identity" "contributor" {
  location            = azurerm_resource_group.spoke.location
  name                = azurecaf_name.contributor_identity.result
  resource_group_name = azurerm_resource_group.spoke.name
}

resource "azurecaf_name" "law" {
  name          = var.application_name
  resource_type = "azurerm_log_analytics_workspace"
  suffixes      = [var.environment]
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = azurecaf_name.law.result
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  # internet_ingestion_enabled = false
}

resource "random_integer" "unique_id" {
  min = 1
  max = 9999
}

resource "azurecaf_name" "spoke_network" {
  name          = "spoke-${var.application_name}"
  resource_type = "azurerm_virtual_network"
  suffixes      = [var.environment]
}

resource "azurecaf_name" "appsvc_subnet" {
  name          = "appsvc"
  resource_type = "azurerm_subnet"
}

resource "azurecaf_name" "ingress_subnet" {
  name          = "ingress"
  resource_type = "azurerm_subnet"
}

resource "azurecaf_name" "devops_subnet" {
  name          = "devops"
  resource_type = "azurerm_subnet"
}

resource "azurecaf_name" "private_link_subnet" {
  name          = "private-link"
  resource_type = "azurerm_subnet"
}

//ToDo: Revisit the default IP ranges to smaller (more realistic)

module "network" {
  source = "../../modules/network"

  resource_group = azurerm_resource_group.spoke.name
  location       = var.location
  name           = azurecaf_name.spoke_network.result
  vnet_cidr      = local.spoke_vnet_cidr

  subnets = [
    {
      name        = azurecaf_name.appsvc_subnet.result
      subnet_cidr = local.appsvc_subnet_cidr
      delegation = {
        name = "Microsoft.Web/serverFarms"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    },
    {
      name        = azurecaf_name.ingress_subnet.result
      subnet_cidr = local.front_door_subnet_cidr
      delegation  = null
    },
    {
      name        = azurecaf_name.devops_subnet.result
      subnet_cidr = local.devops_subnet_cidr
      delegation  = null
    },
    {
      name        = azurecaf_name.private_link_subnet.result
      subnet_cidr = local.private_link_subnet_cidr
      delegation  = null
    }
  ]
}

data "azurerm_virtual_network" "hub" {
  name                = data.terraform_remote_state.hub.outputs.vnet_name
  resource_group_name = data.terraform_remote_state.hub.outputs.rg_name
}

module "private_dns_zones" {
  source = "../../modules/private-dns-zone"

  resource_group = data.terraform_remote_state.hub.outputs.rg_name

  dns_zones = [
    "privatelink.azurewebsites.net",
    "privatelink.database.windows.net",
    "privatelink.azconfig.io",
    "privatelink.vaultcore.azure.net",
    "privatelink.redis.cache.windows.net"
  ]

  vnet_links = [
    {
      vnet_id             = data.azurerm_virtual_network.hub.id
      vnet_resource_group = data.terraform_remote_state.hub.outputs.rg_name
    },
    {
      vnet_id             = module.network.vnet_id
      vnet_resource_group = azurerm_resource_group.spoke.name
    }
  ]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "hub-to-spoke-${var.application_name}"
  resource_group_name          = data.terraform_remote_state.hub.outputs.rg_name
  virtual_network_name         = data.terraform_remote_state.hub.outputs.vnet_name
  remote_virtual_network_id    = module.network.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "spoke-to-hub-${var.application_name}"
  resource_group_name          = azurerm_resource_group.spoke.name
  virtual_network_name         = module.network.vnet_name
  remote_virtual_network_id    = data.azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

module "user_defined_routes" {
  count = var.deployment_options.enable_egress_lockdown ? 1 : 0

  source = "../../modules/user-defined-routes"

  resource_group   = azurerm_resource_group.spoke.name
  location         = var.location
  route_table_name = "egress-lockdown"

  routes = [
    {
      name                   = "defaultRoute"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = data.terraform_remote_state.hub.outputs.firewall_private_ip
    }
  ]

  subnet_ids = module.network.subnets[*].id
}

module "app_service" {
  source = "../../modules/app-service"

  resource_group             = azurerm_resource_group.spoke.name
  application_name           = var.application_name
  environment                = var.environment
  location                   = var.location
  unique_id                  = random_integer.unique_id.result
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  enable_diagnostic_settings = var.deployment_options.enable_diagnostic_settings

  appsvc_subnet_id     = module.network.subnets[index(module.network.subnets.*.name, azurecaf_name.appsvc_subnet.result)].id
  frontend_subnet_id   = module.network.subnets[index(module.network.subnets.*.name, azurecaf_name.ingress_subnet.result)].id
  service_plan_options = var.appsvc_options.service_plan

  identity = {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.reader.id
    ]
  }

  webapp_options = {
    ai_connection_string = module.app_insights.connection_string
    instrumentation_key  = module.app_insights.instrumentation_key
    slots                = var.appsvc_options.web_app.slots
    application_stack    = var.appsvc_options.web_app.application_stack
  }

  private_dns_zone = {
    name           = module.private_dns_zones.dns_zones[index(module.private_dns_zones.dns_zones.*.name, "privatelink.azurewebsites.net")].name
    id             = module.private_dns_zones.dns_zones[index(module.private_dns_zones.dns_zones.*.name, "privatelink.azurewebsites.net")].id
    resource_group = data.terraform_remote_state.hub.outputs.rg_name
  }

  depends_on = [
    module.network,
    module.user_defined_routes,
    module.private_dns_zones,
    azurerm_virtual_network_peering.hub_to_spoke,
    azurerm_virtual_network_peering.spoke_to_hub
  ]
}

//ToDo: Enable extension to deploy DevOps agent

resource "azurecaf_name" "devops_vm" {
  name          = "spoke-${var.application_name}-devops"
  resource_type = "azurerm_windows_virtual_machine"
  suffixes      = [random_integer.unique_id.result]
}

module "devops_vm" {
  count = var.deployment_options.deploy_vm ? 1 : 0

  source = "../../modules/windows-vm"

  resource_group     = azurerm_resource_group.spoke.name
  vm_name            = azurecaf_name.devops_vm.result
  location           = var.location
  vm_subnet_id       = module.network.subnets[index(module.network.subnets.*.name, azurecaf_name.devops_subnet.result)].id
  admin_username     = local.vm_admin_username
  admin_password     = local.vm_admin_password
  aad_admin_username = var.vm_aad_admin_username

  identity = {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.contributor.id
    ]
  }

  depends_on = [
    module.app_configuration,
    module.key_vault,
    module.redis_cache,
    module.sql_database
  ]
}

locals {
  sql_connstring   = length(module.sql_database) > 0 ? module.sql_database[0].sql_db_connection_string : "SQL_NOT_PROVISIONED"
  redis_connstring = length(module.redis_cache) > 0 ? module.redis_cache[0].redis_connection_string : "REDIS_NOT_PROVISIONED"

  az_cli_commands = <<-EOT
    az login --identity --username ${azurerm_user_assigned_identity.contributor.principal_id} --allow-no-subscriptions
    az keyvault secret set --vault-name ${module.key_vault.vault_name} --name 'redis-connstring' --value '${local.redis_connstring}'
    az appconfig kv set --auth-mode login --endpoint ${module.app_configuration[0].endpoint} --key 'sql-connstring' --value '${local.sql_connstring}' --label '${var.environment}' -y
  EOT
}

module "devops_vm_extension" {
  count = var.deployment_options.deploy_vm ? 1 : 0

  source = "../../modules/windows-vm-ext"

  vm_id                = module.devops_vm[0].id
  enable_azure_ad_join = true
  install_ssms         = true
  devops_settings      = var.devops_settings
  azure_cli_commands   = replace(local.az_cli_commands, "\r\n", ";")
}

module "front_door" {
  source = "../../modules/front-door"

  resource_group             = azurerm_resource_group.spoke.name
  application_name           = var.application_name
  environment                = var.environment
  location                   = var.location
  enable_waf                 = var.deployment_options.enable_waf
  unique_id                  = random_integer.unique_id.result
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  enable_diagnostic_settings = var.deployment_options.enable_diagnostic_settings

  endpoint_settings = [
    {
      endpoint_name            = "${var.application_name}-${var.environment}"
      web_app_id               = module.app_service.web_app_id
      web_app_hostname         = module.app_service.web_app_hostname
      private_link_target_type = "sites"
    },

    # Connecting a front door origin to an app service slot through private link is currently not supported
    # {
    #   endpoint_name            = "${var.application_name}-${var.environment}-${var.webapp_slot_name}"
    #   web_app_id               = module.app_service.web_app_id # Note: needs to be the resource id of the app, not the id of the slot
    #   web_app_hostname         = module.app_service.web_app_slot_hostname
    #   private_link_target_type = "sites-${var.slots[0].name]}"
    # }
  ]

  depends_on = [
    module.app_service
  ]
}

module "sql_database" {
  count = var.deployment_options.deploy_sql_database ? 1 : 0

  source = "../../modules/sql-database"

  resource_group            = azurerm_resource_group.spoke.name
  application_name          = var.application_name
  environment               = var.environment
  location                  = var.location
  unique_id                 = random_integer.unique_id.result
  tenant_id                 = local.tenant_id
  aad_admin_group_object_id = var.aad_admin_group_object_id
  aad_admin_group_name      = var.aad_admin_group_name
  private_link_subnet_id    = module.network.subnets[index(module.network.subnets.*.name, azurecaf_name.private_link_subnet.result)].id

  sql_databases = [
    {
      name     = "sample-db"
      sku_name = "S0"
    }
  ]

  private_dns_zone = {
    name           = module.private_dns_zones.dns_zones[index(module.private_dns_zones.dns_zones.*.name, "privatelink.database.windows.net")].name
    id             = module.private_dns_zones.dns_zones[index(module.private_dns_zones.dns_zones.*.name, "privatelink.database.windows.net")].id
    resource_group = data.terraform_remote_state.hub.outputs.rg_name
  }
}

module "app_configuration" {
  count = var.deployment_options.deploy_app_config ? 1 : 0

  source = "../../modules/app-configuration"

  resource_group         = azurerm_resource_group.spoke.name
  application_name       = var.application_name
  environment            = var.environment
  location               = var.location
  unique_id              = random_integer.unique_id.result
  tenant_id              = local.tenant_id
  private_link_subnet_id = module.network.subnets[index(module.network.subnets.*.name, azurecaf_name.private_link_subnet.result)].id

  data_reader_identities = [
    azurerm_user_assigned_identity.reader.principal_id
  ]

  data_owner_identities = [
    azurerm_user_assigned_identity.contributor.principal_id
  ]

  private_dns_zone = {
    name           = module.private_dns_zones.dns_zones[index(module.private_dns_zones.dns_zones.*.name, "privatelink.azconfig.io")].name
    id             = module.private_dns_zones.dns_zones[index(module.private_dns_zones.dns_zones.*.name, "privatelink.azconfig.io")].id
    resource_group = data.terraform_remote_state.hub.outputs.rg_name
  }
}

module "key_vault" {
  source = "../../modules/key-vault"

  resource_group         = azurerm_resource_group.spoke.name
  application_name       = var.application_name
  environment            = var.environment
  location               = var.location
  tenant_id              = local.tenant_id
  unique_id              = random_integer.unique_id.result
  sku_name               = "standard"
  private_link_subnet_id = module.network.subnets[index(module.network.subnets.*.name, azurecaf_name.private_link_subnet.result)].id

  secret_reader_identities = [
    azurerm_user_assigned_identity.reader.principal_id
  ]

  secret_officer_identities = [
    azurerm_user_assigned_identity.contributor.principal_id
  ]

  private_dns_zone = {
    name           = module.private_dns_zones.dns_zones[index(module.private_dns_zones.dns_zones.*.name, "privatelink.vaultcore.azure.net")].name
    id             = module.private_dns_zones.dns_zones[index(module.private_dns_zones.dns_zones.*.name, "privatelink.vaultcore.azure.net")].id
    resource_group = data.terraform_remote_state.hub.outputs.rg_name
  }
}

module "app_insights" {
  source = "../../modules/app-insights"

  resource_group             = azurerm_resource_group.spoke.name
  application_name           = var.application_name
  environment                = var.environment
  location                   = var.location
  web_app_name               = module.app_service.web_app_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

module "redis_cache" {
  count = var.deployment_options.deploy_redis ? 1 : 0

  source = "../../modules/redis-cache"

  resource_group         = azurerm_resource_group.spoke.name
  application_name       = var.application_name
  environment            = var.environment
  location               = var.location
  unique_id              = random_integer.unique_id.result
  sku_name               = "Standard"
  private_link_subnet_id = module.network.subnets[index(module.network.subnets.*.name, azurecaf_name.private_link_subnet.result)].id

  private_dns_zone = {
    name           = module.private_dns_zones.dns_zones[index(module.private_dns_zones.dns_zones.*.name, "privatelink.redis.cache.windows.net")].name
    id             = module.private_dns_zones.dns_zones[index(module.private_dns_zones.dns_zones.*.name, "privatelink.redis.cache.windows.net")].id
    resource_group = data.terraform_remote_state.hub.outputs.rg_name
  }
}
