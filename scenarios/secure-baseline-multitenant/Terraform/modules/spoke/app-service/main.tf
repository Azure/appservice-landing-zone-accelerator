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

  site_config {}
}

resource "azurerm_app_service_virtual_network_swift_connection" "app-svc-network-integration" {
  app_service_id = azurerm_windows_web_app.secure-baseline-web-app.id
  subnet_id      = var.integration-subnet-id
}