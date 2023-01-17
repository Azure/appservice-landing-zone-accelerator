terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.34.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
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

module "spoke_network" {
  source                   = "./network"
  resource_group           = azurerm_resource_group.spoke.name
  application_name         = var.application_name
  environment              = var.environment
  location                 = var.location
  firewall_private_ip      = var.firewall_private_ip
  vnet_cidr                = var.vnet_cidr
  appsvc_int_subnet_cidr   = var.appsvc_int_subnet_cidr
  front_door_subnet_cidr   = var.front_door_subnet_cidr
  devops_subnet_cidr       = var.devops_subnet_cidr
  private_link_subnet_cidr = var.private_link_subnet_cidr
  deployment_options       = var.deployment_options
}

module "app_service" {
  source = "./app-service"

  resource_group       = azurerm_resource_group.spoke.name
  application_name     = var.application_name
  webapp_slot_name     = var.webapp_slot_name
  environment          = var.environment
  location             = var.location
  unique_id            = random_integer.unique_id.result
  sku_name             = "S1"
  os_type              = "Windows"
  instrumentation_key  = module.app_insights.instrumentation_key
  ai_connection_string = module.app_insights.connection_string
  appsvc_subnet_id     = module.spoke_network.appsvc_subnet_id
  frontend_subnet_id   = module.spoke_network.frontend_subnet_id

  private_dns_zone = {
    name = module.spoke_network.azurewebsites_private_dns_zone_name
    id   = module.spoke_network.azurewebsites_private_dns_zone_id
  }
}

module "devops_vm" {
  source = "../shared/windows-vm"

  resource_group     = azurerm_resource_group.spoke.name
  vm_name            = "devops"
  location           = var.location
  vm_subnet_id       = module.spoke_network.devops_subnet_id
  unique_id          = random_integer.unique_id.result
  admin_username     = local.vm_admin_username
  admin_password     = local.vm_admin_password
  aad_admin_username = var.vm_aad_admin_username
  enroll_with_mdm    = true
  install_extensions = true
  firewall_rules     = var.firewall_rules
}

module "front_door" {
  source = "./front-door"

  resource_group   = azurerm_resource_group.spoke.name
  application_name = var.application_name
  environment      = var.environment
  location         = var.location
  enable_waf       = var.deployment_options.enable_waf

  endpoint_settings = [
    {
      endpoint_name            = "${var.application_name}-${var.environment}"
      web_app_id               = module.app_service.web_app_id
      web_app_hostname         = module.app_service.web_app_hostname
      private_link_target_type = "sites"
    },

    # Connecting a front door origin to an app service slot through private link is currently not working
    # {
    #   endpoint_name            = "${var.application_name}-${var.environment}-${var.webapp_slot_name}"
    #   web_app_id               = module.app_service.web_app_id # Note: needs to be the resource id of the app, not the id of the slot
    #   web_app_hostname         = module.app_service.web_app_slot_hostname
    #   private_link_target_type = "sites-${var.webapp_slot_name}"
    # }
  ]
  unique_id = random_integer.unique_id.result

}

module "sql_database" {
  source = "./sql-database"

  resource_group            = azurerm_resource_group.spoke.name
  application_name          = var.application_name
  environment               = var.environment
  location                  = var.location
  unique_id                 = random_integer.unique_id.result
  tenant_id                 = var.tenant_id
  aad_admin_group_object_id = var.aad_admin_group_object_id
  aad_admin_group_name      = var.aad_admin_group_name
  sql_db_name               = "sample-db"
  private-link-subnet-id    = module.spoke_network.private_link_subnet_id
  private_dns_zone_name     = module.spoke_network.sqldb_private_dns_zone_name
}

module "app_configuration" {
  source = "./app-configuration"

  resource_group            = azurerm_resource_group.spoke.name
  application_name          = var.application_name
  environment               = var.environment
  location                  = var.location
  unique_id                 = random_integer.unique_id.result
  tenant_id                 = var.tenant_id
  web_app_principal_id      = module.app_service.web_app_principal_id
  web_app_slot_principal_id = module.app_service.web_app_slot_principal_id
  private_link_subnet_id    = module.spoke_network.private_link_subnet_id
  private_dns_zone_name     = module.spoke_network.appconfig_private_dns_zone_name
  sql_server_name           = module.sql_database.sql_server_name
  sql_db_name               = module.sql_database.sql_db_name
}

module "key_vault" {
  source = "./key-vault"

  resource_group            = azurerm_resource_group.spoke.name
  application_name          = var.application_name
  environment               = var.environment
  location                  = var.location
  tenant_id                 = var.tenant_id
  unique_id                 = random_integer.unique_id.result
  sku_name                  = "standard"
  web_app_principal_id      = module.app_service.web_app_principal_id
  web_app_slot_principal_id = module.app_service.web_app_slot_principal_id
  private_link_subnet_id    = module.spoke_network.private_link_subnet_id
  private_dns_zone_name     = module.spoke_network.keyvault_private_dns_zone_name
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

  resource_group            = azurerm_resource_group.spoke.name
  application_name          = var.application_name
  environment               = var.environment
  location                  = var.location
  unique_id                 = random_integer.unique_id.result
  tenant_id                 = var.tenant_id
  sku_name                  = "Standard"
  private_link_subnet_id    = module.spoke_network.private_link_subnet_id
  private_dns_zone_name     = module.spoke_network.redis_private_dns_zone_name
  web_app_principal_id      = module.app_service.web_app_principal_id
  web_app_slot_principal_id = module.app_service.web_app_slot_principal_id
}
