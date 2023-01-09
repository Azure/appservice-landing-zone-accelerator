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
    category_group = "allLogs"
    enabled        = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  # log {
  #   category = "AZFWApplicationRule"
  #   enabled  = true

  #   retention_policy {
  #     enabled = false
  #     days    = 0
  #   }
  # }

  # log {
  #   category = "AZFWApplicationRuleAggregation"
  #   enabled  = true

  #   retention_policy {
  #     enabled = false
  #     days    = 0
  #   }
  # }

  # log {
  #   category = "AZFWNetworkRule"
  #   enabled  = true

  #   retention_policy {
  #     enabled = false
  #     days    = 0
  #   }
  # }

  # log {
  #   category = "AZFWNetworkRuleAggregation"
  #   enabled  = true

  #   retention_policy {
  #     enabled = false
  #     days    = 0
  #   }
  # }
}

resource "azurerm_firewall_application_rule_collection" "allow-rule-200" {
  name                = "Minimal-Required-FQDNs"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group
  priority            = 200
  action              = "Allow"

  rule {
    name = "allow-rule-200"

    source_addresses = var.firewall_rules_source_addresses

    target_fqdns = [
      "management.azure.com",
      "management.core.windows.net",
      "login.microsoftonline.com",
      "login.windows.net",
      "graph.windows.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "allow-rule-201" {
  name                = "Azure-Monitor-FQDNs"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group
  priority            = 201
  action              = "Allow"

  rule {
    name = "allow-rule-201"

    source_addresses = var.firewall_rules_source_addresses

    target_fqdns = [
      "dc.applicationinsights.azure.com",
      "dc.applicationinsights.microsoft.com",
      "dc.services.visualstudio.com",
      "*.in.applicationinsights.azure.com",
      "live.applicationinsights.azure.com",
      "rt.applicationinsights.microsoft.com",
      "rt.services.visualstudio.com",
      "*.livediagnostics.monitor.azure.com",
      "*.monitoring.azure.com",
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "allow-rule-202" {
  name                = "Packages-and-Tools-FQDNs"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group
  priority            = 202
  action              = "Allow"

  rule {
    name = "allow-rule-202"

    source_addresses = var.firewall_rules_source_addresses

    target_fqdns = [
      "go.microsoft.com",
      "download.microsoft.com",
      "aka.ms",
      "github.com",
      "raw.githubusercontent.com",
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}
