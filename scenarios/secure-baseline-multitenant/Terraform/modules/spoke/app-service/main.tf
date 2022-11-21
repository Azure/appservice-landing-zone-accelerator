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
  sku_name            = "P1v2"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "secure-baseline-web-app" {
  name                = local.web-app-name
  resource_group_name = data.azurerm_resource_group.spoke-rg.name
  location            = data.azurerm_resource_group.spoke-rg.location
  service_plan_id     = azurerm_service_plan.secure-baseline-app-service-plan.id

  site_config {
    vnet_route_all_enabled = true
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "app-svc-network-integration" {
  app_service_id = azurerm_windows_web_app.secure-baseline-web-app.id
  subnet_id      = var.app-svc-integration-subnet-id
}

resource "azurerm_private_endpoint" "app-svc-private-endpoint" {
  name                = "app-svc-private-endpoint"
  resource_group_name = data.azurerm_resource_group.spoke-rg.name
  location            = data.azurerm_resource_group.spoke-rg.location
  subnet_id           = var.front_door_integration_subnet_id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [var.private-dns-zone-id]
  }

  private_service_connection {
    name                           = "app-svc-private-endpoint-connection"
    private_connection_resource_id = azurerm_windows_web_app.secure-baseline-web-app.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}
