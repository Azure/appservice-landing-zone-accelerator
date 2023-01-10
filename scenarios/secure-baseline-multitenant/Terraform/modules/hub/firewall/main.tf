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
  name                           = "tf-firewall-diagnostic-settings"
  target_resource_id             = azurerm_firewall.firewall.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "AzureDiagnostics"

  log {
    category_group = "allLogs"
    enabled        = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "minimal" {
  name                = "Minimal-Required-FQDNs"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group
  priority            = 200
  action              = "Allow"

  rule {
    name = "allow-core"

    source_addresses = var.firewall_rules_source_addresses

    target_fqdns = [
      "management.azure.com",
      "management.core.windows.net",
      "login.microsoftonline.com",
      "login.windows.net",
      "login.live.com",
      "graph.windows.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "azure_monitor" {
  name                = "Azure-Monitor-FQDNs"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group
  priority            = 201
  action              = "Allow"

  rule {
    name = "allow-azure-monitor"

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
      "agent.azureserviceprofiler.net",
      "*.agent.azureserviceprofiler.net",
      "*.monitor.azure.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "windows_vm_devops" {
  name                = "Devops-VM-Dependencies-FQDNs"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group
  priority            = 202
  action              = "Allow"

  rule {
    name = "allow-azure-ad-join"

    source_addresses = var.devops_subnet_cidr

    target_fqdns = [
      "enterpriseregistration.windows.net",
      "login.microsoftonline.com",
      "device.login.microsoftonline.com",
      "autologon.microsoftazuread-sso.com",
      "manage-beta.microsoft.com",
      "manage.microsoft.com",
      "*.manage-beta.microsoft.com",
      "*.manage.microsoft.com",
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "allow-vm-dependencies-and-tools"

    source_addresses = var.devops_subnet_cidr

    target_fqdns = [
      "go.microsoft.com",
      "download.microsoft.com",
      "wdcp.microsoft.com",
      "wdcpalt.microsoft.com",
      "*.data.microsoft.com",
      "aka.ms",
      "github.com",
      "raw.githubusercontent.com",
      "msedge.api.cdp.microsoft.com",
      "*.blob.storage.azure.net",
      "*.blob.core.windows.net",
      "*.dl.delivery.mp.microsoft.com",
      "*.prod.do.dsp.mp.microsoft.com",
      "*.update.microsoft.com",
      "*.windowsupdate.com",
      "*.apps.qualys.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "allow-vm-dependencies-over-http"

    source_addresses = var.devops_subnet_cidr

    target_fqdns = [
      "ctldl.windowsupdate.com"
    ]

    protocol {
      port = "80"
      type = "Http"
    }
  }
}

resource "azurerm_firewall_network_rule_collection" "windows_vm_devops" {
  name                = "Windows-VM-Connectivity-Requirements"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group
  priority            = 202
  action              = "Allow"

  rule {
    name = "allow-kms-activation"
    # Docs: https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/custom-routes-enable-kms-activation

    source_addresses = var.devops_subnet_cidr

    destination_ports = [
      "*"
    ]

    destination_addresses = [
      "20.118.99.224",
      "40.83.235.53",
      "23.102.135.246",
      "51.4.143.248",
      "23.97.0.13",
      "52.126.105.2"
    ]

    protocols = [
      "TCP",
      "UDP",
    ]
  }

  rule {
    name = "allow-ntp"

    source_addresses = var.devops_subnet_cidr

    destination_ports = [
      "123"
    ]

    destination_addresses = [
      "*"
    ]

    protocols = [
      "TCP",
      "UDP",
    ]
  }
}
