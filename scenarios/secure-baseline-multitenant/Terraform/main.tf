terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.30.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
    azapi = {
      source = "azure/azapi"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

provider "azapi" {
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}

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
  app-svc-integration-subnet-id    = module.spoke-network.app_svc_integration_subnet_id
  front_door_integration_subnet_id = module.spoke-network.front_door_integration_subnet_id
  private-dns-zone-id              = module.spoke-network.azurewebsites_private_dns_zone_id
}
