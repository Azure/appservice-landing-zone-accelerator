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

resource "random_integer" "unique-id" {
  min = 1000
  max = 9999
}

module "spoke-network" {
  source                   = "./network"
  resource_group           = azurerm_resource_group.spoke.name
  application_name         = var.application_name
  environment              = var.environment
  location                 = var.location
  vnet_cidr                = var.vnet_cidr
  appsvc_int_subnet_cidr   = var.appsvc_int_subnet_cidr
  front_door_subnet_cidr   = var.front_door_subnet_cidr
  devops_subnet_cidr       = var.devops_subnet_cidr
  private_link_subnet_cidr = var.private_link_subnet_cidr
}

module "app-service" {
  source                           = "./app-service"
  resource_group                   = azurerm_resource_group.spoke.name
  application_name                 = var.application_name
  environment                      = var.environment
  location                         = var.location
  unique_id                        = random_integer.unique-id.result
  sku_name                         = "S1"
  os_type                          = "Windows"
  instrumentation_key              = module.app-insights.instrumentation_key
  app_insights_connection_string   = module.app-insights.connection_string
  app_svc_integration_subnet_id    = module.spoke-network.app_svc_integration_subnet_id
  front_door_integration_subnet_id = module.spoke-network.front_door_integration_subnet_id
  private_dns_zone_id              = module.spoke-network.azurewebsites_private_dns_zone_id
}

module "devops-vm" {
  source             = "./devops-vm"
  resource_group     = azurerm_resource_group.spoke.name
  vm_name            = "devops-vm"
  vm_subnet_id       = module.spoke-network.devops_subnet_id
  unique_id          = random_integer.unique-id.result
  admin_username     = var.vm_admin_username
  admin_password     = var.vm_admin_password
  aad_admin_username = var.vm_aad_admin_username
  enroll_with_mdm    = true
  location           = var.location
  install_extensions = true
}

module "front-door" {
  source           = "./front-door"
  resource_group   = azurerm_resource_group.spoke.name
  application_name = var.application_name
  environment      = var.environment
  location         = var.location
  web_app_id       = module.app-service.web_app_id
  web_app_hostname = module.app-service.web_app_hostname
  enable_waf       = var.enable_waf
}

module "sql-database" {
  source                    = "./sql-database"
  resource_group            = azurerm_resource_group.spoke.name
  application_name          = var.application_name
  environment               = var.environment
  location                  = var.location
  unique_id                 = random_integer.unique-id.result
  tenant_id                 = var.tenant_id
  aad_admin_group_object_id = var.aad_admin_group_object_id
  aad_admin_group_name      = var.aad_admin_group_name
  sql_db_name               = "sample-db"
  private-link-subnet-id    = module.spoke-network.private_link_subnet_id
  private_dns_zone_name     = module.spoke-network.sqldb_private_dns_zone_name
}

module "app-configuration" {
  source                    = "./app-configuration"
  resource_group            = azurerm_resource_group.spoke.name
  application_name          = var.application_name
  environment               = var.environment
  location                  = var.location
  unique_id                 = random_integer.unique-id.result
  tenant_id                 = var.tenant_id
  web_app_principal_id      = module.app-service.web_app_principal_id
  web_app_slot_principal_id = module.app-service.web_app_slot_principal_id
  private_link_subnet_id    = module.spoke-network.private_link_subnet_id
  private_dns_zone_name     = module.spoke-network.appconfig_private_dns_zone_name
  sql_server_name           = module.sql-database.sql_server_name
  sql_db_name               = module.sql-database.sql_db_name
  # sql_db_id                   = module.sql-database.sql_db_id
  # sql_db_name                 = module.sql-database.sql_db_name
  # sql_db_server               = module.sql-database.sql_db_server
  # sql_db_tenant_id            = module.sql-database.sql_db_tenant_id
}

module "key-vault" {
  source                    = "./key-vault"
  resource_group            = azurerm_resource_group.spoke.name
  application_name          = var.application_name
  environment               = var.environment
  location                  = var.location
  tenant_id                 = var.tenant_id
  unique_id                 = random_integer.unique-id.result
  sku_name                  = "standard"
  web_app_principal_id      = module.app-service.web_app_principal_id
  web_app_slot_principal_id = module.app-service.web_app_slot_principal_id
  private_link_subnet_id    = module.spoke-network.private_link_subnet_id
  private_dns_zone_name     = module.spoke-network.keyvault_private_dns_zone_name
}

module "app-insights" {
  source           = "./app-insights"
  resource_group   = azurerm_resource_group.spoke.name
  application_name = var.application_name
  environment      = var.environment
  location         = var.location
  web_app_name     = module.app-service.web_app_name
}
