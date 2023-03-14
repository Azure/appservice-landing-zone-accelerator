terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.23"
    }
  }
}

resource "random_password" "vm_admin_username" {
  length  = 10
  special = false
}

resource "random_password" "vm_admin_password" {
  length  = 16
  special = true
}

locals {
  vm_admin_username = var.vm_admin_username == null ? random_password.vm_admin_username.result : var.vm_admin_username
  vm_admin_password = var.vm_admin_password == null ? random_password.vm_admin_password.result : var.vm_admin_password
}

resource "azurecaf_name" "resource_group" {
  name          = var.application_name
  resource_type = "azurerm_resource_group"
  suffixes      = [var.environment]
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
  name          = var.application_name
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

//ToDo: Determine if it makes sense to have the ingress subnet or just use the private link subnet
//ToDo: Revisit the default IP ranges to smaller (more realistic)

module "network" {
  source = "../shared/network"

  resource_group = azurerm_resource_group.spoke.name
  location       = var.location
  name           = azurecaf_name.spoke_network.result
  vnet_cidr      = var.vnet_cidr

  subnets = [
    {
      name        = azurecaf_name.appsvc_subnet.result
      subnet_cidr = var.appsvc_subnet_cidr
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
      subnet_cidr = var.front_door_subnet_cidr
      delegation  = null
    },
    {
      name        = azurecaf_name.devops_subnet.result
      subnet_cidr = var.devops_subnet_cidr
      delegation  = null
    },
    {
      name        = azurecaf_name.private_link_subnet.result
      subnet_cidr = var.private_link_subnet_cidr
      delegation  = null
    }
  ]
}

module "user_defined_routes" {
  count = var.deployment_options.enable_egress_lockdown ? 1 : 0

  source = "../shared/user-defined-routes"

  resource_group   = azurerm_resource_group.spoke.name
  location         = var.location
  route_table_name = "egress-lockdown"

  routes = [
    {
      name                   = "defaultRoute"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip
    }
  ]

  subnet_ids = module.network.subnets[*].id
}

//ToDo: System assigned identities vs user assigned identities
//ToDo: Add Redis Cache connectiong string reference to app settings (Key Vault)
//ToDo: Add SQL Server connectiong string reference to app settings (App Config)

module "app_service" {
  source = "./app-service"

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

  webapp_options = {
    ai_connection_string = module.app_insights.connection_string
    instrumentation_key  = module.app_insights.instrumentation_key
    slots                = var.appsvc_options.web_app.slots
    application_stack    = var.appsvc_options.web_app.application_stack
  }

  private_dns_zone = {
    name           = var.private_dns_zones[index(var.private_dns_zones.*.name, "privatelink.azurewebsites.net")].name
    id             = var.private_dns_zones[index(var.private_dns_zones.*.name, "privatelink.azurewebsites.net")].id
    resource_group = var.private_dns_zones_rg
  }
}

//ToDo: Enable extension to deploy DevOps agent

resource "azurecaf_name" "devops_vm" {
  name          = "devops"
  resource_type = "azurerm_windows_virtual_machine"
  suffixes      = [random_integer.unique_id.result]
}

module "devops_vm" {
  count = var.deployment_options.deploy_vm ? 1 : 0

  source = "../shared/windows-vm"

  resource_group     = azurerm_resource_group.spoke.name
  vm_name            = azurecaf_name.devops_vm.result
  location           = var.location
  vm_subnet_id       = module.network.subnets[index(module.network.subnets.*.name, azurecaf_name.devops_subnet.result)].id
  admin_username     = local.vm_admin_username
  admin_password     = local.vm_admin_password
  aad_admin_username = var.vm_aad_admin_username
}

module "devops_vm_extension" {
  count = var.deployment_options.deploy_vm ? 1 : 0

  source = "../shared/windows-vm-ext"

  vm_id = module.devops_vm[0].id

  enable_azure_ad_join = true
  install_extensions   = false
}

locals {
  sql_connstring = length(module.sql_database) > 0 ? module.sql_database[0].sql_db_connection_string : "<NOT PROVISIONED>"
  redis_connstring = length(module.redis_cache) > 0 ? module.redis_cache[0].redis_cache_connection_string : "<NOT PROVISIONED>"

  az_cli_commands = <<-EOT
    az login --identity --allow-no-subscriptions
    az keyvault secret set --vault-name ${module.key_vault.vault_name} --name redis_connstring --value ${local.redis_connstring}
    az appconfig kv set --auth-mode login --endpoint ${module.app_configuration[0].endpoint} --key sql_connstring --value ${local.sql_connstring} --label ${var.environment} -y
  EOT
}

resource "azurerm_virtual_machine_extension" "az_cli_runner" {
  count = var.deployment_options.deploy_vm ? 1 : 0

  name                 = "az_cli_runner_v2"
  virtual_machine_id   = module.devops_vm[0].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File az-cli-runner.ps1 -command ${replace(local.az_cli_commands, "\r\n", ";")}",
        "fileUris": ["https://raw.githubusercontent.com/Azure/appservice-landing-zone-accelerator/feature/secure-baseline-scenario-v2/scenarios/secure-baseline-multitenant/terraform/modules/shared/windows-vm-ext/az-cli-runner.ps1"]
    }
  PROTECTED_SETTINGS

  timeouts {
    create = "30m"
  }
}

module "front_door" {
  source = "./front-door"

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
    #   private_link_target_type = "sites-${var.webapp_slot_name}"
    # }
  ]

  depends_on = [
    module.app_service
  ]
}

module "sql_database" {
  count = var.deployment_options.deploy_sql_database ? 1 : 0

  source = "./sql-database"

  resource_group            = azurerm_resource_group.spoke.name
  application_name          = var.application_name
  environment               = var.environment
  location                  = var.location
  unique_id                 = random_integer.unique_id.result
  tenant_id                 = var.tenant_id
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
    name           = var.private_dns_zones[index(var.private_dns_zones.*.name, "privatelink.database.windows.net")].name
    id             = var.private_dns_zones[index(var.private_dns_zones.*.name, "privatelink.database.windows.net")].id
    resource_group = var.private_dns_zones_rg
  }
}

//ToDo: Add SQL Database connectiong string (without secrets) 

module "app_configuration" {
  count = var.deployment_options.deploy_app_config ? 1 : 0

  source = "./app-configuration"

  resource_group         = azurerm_resource_group.spoke.name
  application_name       = var.application_name
  environment            = var.environment
  location               = var.location
  unique_id              = random_integer.unique_id.result
  tenant_id              = var.tenant_id
  private_link_subnet_id = module.network.subnets[index(module.network.subnets.*.name, azurecaf_name.private_link_subnet.result)].id

  data_reader_identities = [
    module.app_service.web_app_principal_id,
    module.app_service.web_app_slot_principal_id
  ]

  data_owner_identities = [
    module.devops_vm[0].principal_id
  ]

  private_dns_zone = {
    name           = var.private_dns_zones[index(var.private_dns_zones.*.name, "privatelink.azconfig.io")].name
    id             = var.private_dns_zones[index(var.private_dns_zones.*.name, "privatelink.azconfig.io")].id
    resource_group = var.private_dns_zones_rg
  }
}

//ToDo: Add Redis Cache connectiong string (without secrets) 

module "key_vault" {
  source = "./key-vault"

  resource_group         = azurerm_resource_group.spoke.name
  application_name       = var.application_name
  environment            = var.environment
  location               = var.location
  tenant_id              = var.tenant_id
  unique_id              = random_integer.unique_id.result
  sku_name               = "standard"
  private_link_subnet_id = module.network.subnets[index(module.network.subnets.*.name, azurecaf_name.private_link_subnet.result)].id

  secret_reader_identities = [
    module.app_service.web_app_principal_id,
    module.app_service.web_app_slot_principal_id
  ]

  secret_officer_identities = [
    module.devops_vm[0].principal_id
  ]

  private_dns_zone = {
    name           = var.private_dns_zones[index(var.private_dns_zones.*.name, "privatelink.vaultcore.azure.net")].name
    id             = var.private_dns_zones[index(var.private_dns_zones.*.name, "privatelink.vaultcore.azure.net")].id
    resource_group = var.private_dns_zones_rg
  }
}

module "app_insights" {
  source = "./app-insights"

  resource_group             = azurerm_resource_group.spoke.name
  application_name           = var.application_name
  environment                = var.environment
  location                   = var.location
  web_app_name               = module.app_service.web_app_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

module "redis_cache" {
  count = var.deployment_options.deploy_redis ? 1 : 0

  source = "./redis-cache"

  resource_group         = azurerm_resource_group.spoke.name
  application_name       = var.application_name
  environment            = var.environment
  location               = var.location
  unique_id              = random_integer.unique_id.result
  sku_name               = "Standard"
  private_link_subnet_id = module.network.subnets[index(module.network.subnets.*.name, azurecaf_name.private_link_subnet.result)].id

  private_dns_zone = {
    name           = var.private_dns_zones[index(var.private_dns_zones.*.name, "privatelink.redis.cache.windows.net")].name
    id             = var.private_dns_zones[index(var.private_dns_zones.*.name, "privatelink.redis.cache.windows.net")].id
    resource_group = var.private_dns_zones_rg
  }
}
