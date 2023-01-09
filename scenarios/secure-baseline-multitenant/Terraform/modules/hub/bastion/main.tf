terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

resource "azurecaf_name" "bastion-pip" {
  name          = "bastion"
  resource_type = "azurerm_public_ip"
  suffixes      = [var.location]
}

resource "azurerm_public_ip" "bastion-pip" {
  name                = azurecaf_name.bastion-pip.result
  resource_group_name = var.resource_group
  location            = var.location
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
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Standard"
  tunneling_enabled   = true

  ip_configuration {
    name                 = "bastionHostIpConfiguration"
    subnet_id            = "${var.hub_vnet_id}/subnets/AzureBastionSubnet"
    public_ip_address_id = azurerm_public_ip.bastion-pip.id
  }
}