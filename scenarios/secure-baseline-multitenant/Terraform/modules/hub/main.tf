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

module "bastion" {
  source = "./bastion"

  resource_group = azurerm_resource_group.hub.name
  location       = azurerm_resource_group.hub.location
  hub_vnet_id    = azurerm_virtual_network.hub_vnet.id
}

module "firewall" {
  count  = var.deploy_firewall ? 1 : 0
  source = "./firewall"

  resource_group = azurerm_resource_group.hub.name
  location       = azurerm_resource_group.hub.location
  hub_vnet_id    = azurerm_virtual_network.hub_vnet.id
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
