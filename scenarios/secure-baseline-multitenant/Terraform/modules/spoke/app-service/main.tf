provider "azurerm" {
  features {}
}
data "azurerm_resource_group" "spoke-rg" {
  name = var.resource_group
}

locals {
  app-svc-plan-name = "plan-${var.application_name}-${var.environment}"
  web-app-name      = "web-${var.application_name}-${var.environment}"
}

resource "azurerm_service_plan" "secure-baseline-app-service-plan" {
  name                = local.app-svc-plan-name
  resource_group_name = data.azurerm_resource_group.spoke-rg.name
  location            = data.azurerm_resource_group.spoke-rg.location
  sku_name            = var.sku_name
  os_type             = var.os_type
}

resource "azurerm_windows_web_app" "secure-baseline-web-app" {
  name                      = local.web-app-name
  resource_group_name       = data.azurerm_resource_group.spoke-rg.name
  location                  = data.azurerm_resource_group.spoke-rg.location
  service_plan_id           = azurerm_service_plan.secure-baseline-app-service-plan.id
  virtual_network_subnet_id = var.app_svc_integration_subnet_id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    vnet_route_all_enabled = true
  }
}

resource "azurerm_windows_web_app_slot" "secure-baseline-web-app-slot" {
  name           = "${local.web-app-name}-slot"
  app_service_id = azurerm_windows_web_app.secure-baseline-web-app.id

  site_config {}
}

resource "azurerm_app_service_source_control_slot" "sample-app" {
  slot_id                = azurerm_windows_web_app_slot.secure-baseline-web-app-slot.id
  repo_url               = "https://github.com/Azure/appservice-landing-zone-accelerator"
  branch                 = "main"
  use_manual_integration = true
}

resource "azurerm_private_endpoint" "app-svc-private-endpoint" {
  name                = "app-svc-private-endpoint"
  resource_group_name = data.azurerm_resource_group.spoke-rg.name
  location            = data.azurerm_resource_group.spoke-rg.location
  subnet_id           = var.front_door_integration_subnet_id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  private_service_connection {
    name                           = "app-svc-private-endpoint-connection"
    private_connection_resource_id = azurerm_windows_web_app.secure-baseline-web-app.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}
