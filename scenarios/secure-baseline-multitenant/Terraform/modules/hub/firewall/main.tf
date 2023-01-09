terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

resource "azurecaf_name" "firewall-pip" {
  name          = "firewall"
  resource_type = "azurerm_public_ip"
}

resource "azurerm_public_ip" "firewall-pip" {
  name                = azurecaf_name.firewall-pip.result
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurecaf_name" "firewall" {
  name          = "firewall"
  resource_type = "azurerm_firewall"
}

resource "azurerm_firewall" "firewall-standard" {
  name                = azurecaf_name.firewall.result
  resource_group_name = var.resource_group
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "firewallIpConfiguration"
    subnet_id            = "${var.hub_vnet_id}/subnets/AzureFirewallSubnet"
    public_ip_address_id = azurerm_public_ip.firewall-pip.id
  }
}
