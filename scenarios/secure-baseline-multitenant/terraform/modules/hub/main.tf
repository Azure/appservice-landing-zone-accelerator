terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

resource "azurecaf_name" "resource_group" {
  name          = "hub"
  resource_type = "azurerm_resource_group"
  suffixes      = [var.location]
}

resource "azurerm_resource_group" "hub" {
  name     = azurecaf_name.resource_group.result
  location = var.location

  tags = {
    "terraform" = "true"
  }
}

resource "azurecaf_name" "law" {
  name          = "hub"
  resource_type = "azurerm_log_analytics_workspace"
  suffixes      = [var.location]
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = azurecaf_name.law.result
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "PerGB2018"
  # internet_ingestion_enabled = false
}

module "bastion" {
  source = "./bastion"

  resource_group = azurerm_resource_group.hub.name
  location       = azurerm_resource_group.hub.location
  hub_vnet_id    = azurerm_virtual_network.hub_vnet.id
}

module "firewall" {
  count  = var.deploy_firewall ? 1 : 0
  
  source = "./firewall"

  resource_group                  = azurerm_resource_group.hub.name
  location                        = azurerm_resource_group.hub.location
  hub_vnet_id                     = azurerm_virtual_network.hub_vnet.id
  log_analytics_workspace_id      = azurerm_log_analytics_workspace.law.id
  firewall_rules_source_addresses = var.firewall_rules_source_addresses
  devops_subnet_cidr              = var.devops_subnet_cidr
}

resource "azurecaf_name" "hub_vnet" {
  name          = "hub"
  resource_type = "azurerm_virtual_network"
  suffixes      = [var.location]
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = azurecaf_name.hub_vnet.result
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = var.vnet_cidr

  subnet {
    name           = "AzureFirewallSubnet"
    address_prefix = var.firewall_subnet_cidr
  }

  subnet {
    name           = "AzureBastionSubnet"
    address_prefix = var.bastion_subnet_cidr
  }
}
