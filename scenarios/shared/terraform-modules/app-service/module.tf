locals {
  webapp_options = merge({
    ai_connection_string = azurerm_application_insights.this.connection_string
    instrumentation_key  = azurerm_application_insights.this.instrumentation_key
  }, var.webapp_options)

  # If isolated SKU (using App Service Environment) then do not enable vnet integration
  is_isolated_sku = can(regex("(?i)^I.*v2$", var.service_plan_options.sku_name))
}

resource "azurecaf_name" "caf_name_asp" {
  name          = var.application_name
  resource_type = "azurerm_app_service_plan"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough

  use_slug = var.global_settings.use_slug
}

resource "azurerm_service_plan" "this" {
  name                = azurecaf_name.caf_name_asp.result
  resource_group_name = var.resource_group
  location            = var.location
  sku_name            = var.service_plan_options.sku_name
  os_type             = var.service_plan_options.os_type

  app_service_environment_id = var.app_service_environment_id
  worker_count               = coalesce(var.service_plan_options.worker_count, 3)

  # For ASEv3 hosted ASP, zone redundancy is managed at the ASE level
  zone_balancing_enabled = var.app_service_environment_id != null ? true : false

  tags = local.tags
}

module "windows_web_app" {
  count = var.deploy_web_app ? (var.service_plan_options.os_type == "Windows" ? 1 : 0) : 0

  source = "./windows-web-app"

  resource_group = var.resource_group
  web_app_name   = var.application_name
  # environment           = var.environment
  location              = var.location
  service_plan_id       = azurerm_service_plan.this.id
  service_plan_resource = azurerm_service_plan.this

  # If isolated SKU (using App Service Environment) then do not enable vnet integration
  appsvc_subnet_id   = local.is_isolated_sku == true ? null : var.appsvc_subnet_id
  frontend_subnet_id = var.frontend_subnet_id
  webapp_options     = local.webapp_options
  private_dns_zone   = var.private_dns_zone
  identity           = var.identity
  global_settings    = var.global_settings
  tags               = var.tags

  log_analytics_workspace_id = var.log_analytics_workspace_id
  enable_diagnostic_settings = var.enable_diagnostic_settings
}

module "linux_web_app" {
  count = var.deploy_web_app ? (var.service_plan_options.os_type == "Linux" ? 1 : 0) : 0

  source = "./linux-web-app"

  resource_group = var.resource_group
  web_app_name   = var.application_name
  # environment           = var.environment
  location              = var.location
  service_plan_id       = azurerm_service_plan.this.id
  service_plan_resource = azurerm_service_plan.this

  # If isolated SKU (using App Service Environment) then do not enable vnet integration
  appsvc_subnet_id   = local.is_isolated_sku == true ? null : var.appsvc_subnet_id
  frontend_subnet_id = var.frontend_subnet_id
  webapp_options     = local.webapp_options
  private_dns_zone   = var.private_dns_zone
  identity           = var.identity
  global_settings    = var.global_settings
  tags               = var.tags

  log_analytics_workspace_id = var.log_analytics_workspace_id
  enable_diagnostic_settings = var.enable_diagnostic_settings
}

# Only required for vnet integration (non ASE)
resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  count          = local.is_isolated_sku == true ? 0 : 1
  app_service_id = var.deploy_web_app ? length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_id : module.linux_web_app[0].web_app_id : null
  subnet_id      = var.appsvc_subnet_id
}
