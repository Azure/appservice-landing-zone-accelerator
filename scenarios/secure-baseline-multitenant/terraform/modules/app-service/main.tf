terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.23"
    }
  }
}

locals {
  appsvc-plan-name = "asp-${var.application_name}-${substr(lower(var.service_plan_options.os_type), 0, 3)}-${var.environment}"
  web-app-name     = "app-${var.application_name}-${var.environment}-${var.unique_id}"
}

resource "azurerm_service_plan" "this" {
  name                = local.appsvc-plan-name
  resource_group_name = var.resource_group
  location            = var.location
  sku_name            = var.service_plan_options.sku_name
  os_type             = var.service_plan_options.os_type

  worker_count           = coalesce(var.service_plan_options.worker_count, 1)
  zone_balancing_enabled = coalesce(var.service_plan_options.zone_redundant, false)
}

module "windows_web_app" {
  count = var.service_plan_options.os_type == "Windows" ? 1 : 0

  source = "./windows-web-app"

  resource_group        = var.resource_group
  web_app_name          = local.web-app-name
  environment           = var.environment
  location              = var.location
  unique_id             = var.unique_id
  service_plan_id       = azurerm_service_plan.this.id
  service_plan_resource = azurerm_service_plan.this
  appsvc_subnet_id      = var.appsvc_subnet_id
  frontend_subnet_id    = var.frontend_subnet_id
  webapp_options        = var.webapp_options
  private_dns_zone      = var.private_dns_zone
  identity              = var.identity

  log_analytics_workspace_id = var.log_analytics_workspace_id
  enable_diagnostic_settings = var.enable_diagnostic_settings
}

module "linux_web_app" {
  count = var.service_plan_options.os_type == "Linux" ? 1 : 0

  source = "./linux-web-app"

  resource_group        = var.resource_group
  web_app_name          = local.web-app-name
  environment           = var.environment
  location              = var.location
  unique_id             = var.unique_id
  service_plan_id       = azurerm_service_plan.this.id
  service_plan_resource = azurerm_service_plan.this
  appsvc_subnet_id      = var.appsvc_subnet_id
  frontend_subnet_id    = var.frontend_subnet_id
  webapp_options        = var.webapp_options
  private_dns_zone      = var.private_dns_zone
  identity              = var.identity

  log_analytics_workspace_id = var.log_analytics_workspace_id
  enable_diagnostic_settings = var.enable_diagnostic_settings
}
