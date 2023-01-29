terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

resource "azurecaf_name" "bastion_host" {
  name          = "hub"
  resource_type = "azurerm_bastion_host"
  suffixes      = [var.location]
}

resource "azurecaf_name" "bastion_pip" {
  name          = azurecaf_name.bastion_host.result
  resource_type = "azurerm_public_ip"
}

resource "azurerm_public_ip" "bastion_pip" {
  name                = azurecaf_name.bastion_pip.result
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = azurecaf_name.bastion_host.result
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Standard"
  tunneling_enabled   = true

  ip_configuration {
    name                 = "bastionHostIpConfiguration"
    subnet_id            = "${var.hub_vnet_id}/subnets/AzureBastionSubnet"
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}