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
    # azapi = {
    #   source = "azure/azapi"
    # }
    # azuread = {
    #   source = "hashicorp/azuread"
    # }
  }
}

provider "azurerm" {
  features {}
}

# provider "azapi" {
# }

# provider "azuread" {
# }

locals {
  // If an environment is set up (dev, test, prod...), it is used in the application name
  environment = var.environment == "" ? "dev" : var.environment
}

resource "azurecaf_name" "resource_group" {
  name          = var.application_name
  resource_type = "azurerm_resource_group"
  suffixes      = [local.environment]
}

resource "azurerm_resource_group" "main" {
  name     = azurecaf_name.resource_group.result
  location = var.location

  tags = {
    "terraform"        = "true"
    "environment"      = local.environment
    "application-name" = var.application_name
  }
}

resource "random_integer" "unique-id" {
  min = 1000
  max = 9999
}

module "spoke-network" {
  source           = "./modules/spoke/network"
  resource_group   = azurerm_resource_group.main.name
  application_name = var.application_name
  environment      = local.environment
  location         = var.location
}

module "app-service" {
  source                           = "./modules/spoke/app-service"
  resource_group                   = azurerm_resource_group.main.name
  application_name                 = var.application_name
  environment                      = local.environment
  location                         = var.location
  unique_id                        = random_integer.unique-id.result
  sku_name                         = "S1"
  os_type                          = "Windows"
  app_svc_integration_subnet_id    = module.spoke-network.app_svc_integration_subnet_id
  front_door_integration_subnet_id = module.spoke-network.front_door_integration_subnet_id
  private_dns_zone_id              = module.spoke-network.azurewebsites_private_dns_zone_id
}

module "front-door" {
  source           = "./modules/spoke/front-door"
  resource_group   = azurerm_resource_group.main.name
  application_name = var.application_name
  environment      = local.environment
  location         = var.location
  web_app_id       = module.app-service.web_app_id
  web_app_hostname = module.app-service.web_app_hostname
}

module "sql-database" {
  source                      = "./modules/spoke/sql-database"
  resource_group              = azurerm_resource_group.main.name
  application_name            = var.application_name
  environment                 = local.environment
  location                    = var.location
  unique_id                   = random_integer.unique-id.result
  tenant_id                   = var.tenant_id
  sql_admin_group_object_id   = var.sql_admin_group_object_id
  sql_admin_group_name        = var.sql_admin_group_name
  sql_db_name                 = "sample-db"
  private-link-subnet-id      = module.spoke-network.private_link_subnet_id
  sqldb_private_dns_zone_name = module.spoke-network.sqldb_private_dns_zone_name
}

module "app-configuration" {
  source                 = "./modules/spoke/app-configuration"
  resource_group         = azurerm_resource_group.main.name
  application_name       = var.application_name
  environment            = local.environment
  location               = var.location
  unique_id              = random_integer.unique-id.result
  tenant_id              = var.tenant_id
  web_app_identity       = module.app-service.web_app_identity_principal_id
  private_link_subnet_id = module.spoke-network.private_link_subnet_id
  private_dns_zone_name  = module.spoke-network.appconfig_private_dns_zone_name
  sql_server_name        = module.sql-database.sql_server_name
  sql_db_name            = module.sql-database.sql_db_name
  # sql_db_id                   = module.sql-database.sql_db_id
  # sql_db_name                 = module.sql-database.sql_db_name
  # sql_db_server               = module.sql-database.sql_db_server
  # sql_db_tenant_id            = module.sql-database.sql_db_tenant_id
}
