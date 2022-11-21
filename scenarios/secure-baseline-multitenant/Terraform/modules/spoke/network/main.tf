terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

resource "azurecaf_name" "spoke_vnet" {
  name          = var.application_name
  resource_type = "azurerm_virtual_network"
  suffixes      = [var.environment]
}

data "azurerm_resource_group" "spoke-rg" {
  name = var.resource_group
}

resource "azurerm_virtual_network" "spoke-vnet" {
  address_space       = ["10.240.0.0/20"]
  location            = var.location
  name                = azurecaf_name.spoke_vnet.result
  resource_group_name = var.resource_group
  depends_on = [
    data.azurerm_resource_group.spoke-rg,
  ]
}

resource "azurecaf_name" "app-svc-integration-subnet" {
  name          = "app-svc-integration"
  resource_type = "azurerm_subnet"
  # suffixes      = [var.environment]
}

# https://learn.microsoft.com/en-us/azure/app-service/overview-vnet-integration
resource "azurerm_subnet" "app-svc-integration-subnet" {
  address_prefixes     = ["10.240.0.0/26"]
  name                 = azurecaf_name.app-svc-integration-subnet.result
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.spoke-vnet.name

  delegation {
    name = "app-svc-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurecaf_name" "front-door-integration-subnet" {
  name          = "front-door-integration"
  resource_type = "azurerm_subnet"
  # suffixes      = [var.environment]
}

# https://learn.microsoft.com/en-us/azure/app-service/networking/private-endpoint
resource "azurerm_subnet" "front-door-integration-subnet" {
  address_prefixes     = ["10.240.0.64/26"]
  name                 = azurecaf_name.front-door-integration-subnet.result
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.spoke-vnet.name
}

resource "azurecaf_name" "devops-subnet" {
  name          = "devops"
  resource_type = "azurerm_subnet"
  # suffixes      = [var.environment]
}

resource "azurerm_subnet" "devops-subnet" {
  address_prefixes     = ["10.240.10.128/25"]
  name                 = azurecaf_name.devops-subnet.result
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.spoke-vnet.name
}

resource "azurecaf_name" "private-link-subnet" {
  name          = "private-link"
  resource_type = "azurerm_subnet"
  # suffixes      = [var.environment]
}

resource "azurerm_subnet" "private-link-subnet" {
  address_prefixes     = ["10.240.11.0/24"]
  name                 = azurecaf_name.private-link-subnet.result
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.spoke-vnet.name
}