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

resource "azurecaf_name" "bastion-pip" {
  name          = "bastion"
  resource_type = "azurerm_public_ip"
  suffixes      = [var.location]
}

resource "azurerm_public_ip" "bastion-pip" {
  name                = azurecaf_name.bastion-pip.result
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurecaf_name" "bastion-host" {
  name          = "hub"
  resource_type = "azurerm_bastion_host"
  suffixes      = [var.location]
}

resource "azurerm_bastion_host" "bastion" {
  name                = azurecaf_name.bastion-host.result
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "Standard"
  tunneling_enabled   = true

  ip_configuration {
    name                 = "bastionHostIpConfiguration"
    subnet_id            = "${azurerm_virtual_network.hub_vnet.id}/subnets/AzureBastionSubnet"
    public_ip_address_id = azurerm_public_ip.bastion-pip.id
  }
  # depends_on = [azurerm_virtual_network.vnetHub, azurerm_virtual_network.vnetSpoke]
}

resource "azurecaf_name" "firewall-pip" {
  count         = var.deploy_firewall ? 1 : 0
  name          = "firewall"
  resource_type = "azurerm_public_ip"
}

resource "azurerm_public_ip" "firewall-pip" {
  count               = var.deploy_firewall ? 1 : 0
  name                = azurecaf_name.firewall-pip[0].result
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurecaf_name" "firewall" {
  count         = var.deploy_firewall ? 1 : 0
  name          = "firewall"
  resource_type = "azurerm_firewall"
}

resource "azurerm_firewall" "firewall-standard" {
  count               = var.deploy_firewall ? 1 : 0
  name                = azurecaf_name.firewall[0].result
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "firewallIpConfiguration"
    subnet_id            = "${azurerm_virtual_network.hub_vnet.id}/subnets/AzureFirewallSubnet"
    public_ip_address_id = azurerm_public_ip.firewall-pip[0].id
  }
}
