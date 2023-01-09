terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

resource "azurecaf_name" "firewall" {
  name          = "hub"
  resource_type = "azurerm_firewall"
  suffixes      = [var.location]
}

resource "azurecaf_name" "firewall_pip" {
  name          = azurecaf_name.firewall.result
  resource_type = "azurerm_public_ip"
}

resource "azurerm_public_ip" "firewall_pip" {
  name                = azurecaf_name.firewall_pip.result
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "firewall" {
  name                = azurecaf_name.firewall.result
  resource_group_name = var.resource_group
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "firewallIpConfiguration"
    subnet_id            = "${var.hub_vnet_id}/subnets/AzureFirewallSubnet"
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }
}

resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostic_settings" {
  name                       = "tf-firewall-diagnostic-settings"
  target_resource_id         = azurerm_firewall.firewall.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "AzureFirewallApplicationRule"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AzureFirewallNetworkRule"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}
