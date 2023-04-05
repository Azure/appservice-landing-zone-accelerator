terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
    }
  }
}

resource "azurecaf_name" "bastion_pip" {
  name          = var.name
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
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Standard"
  tunneling_enabled   = true

  ip_configuration {
    name                 = "bastionHostIpConfiguration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}