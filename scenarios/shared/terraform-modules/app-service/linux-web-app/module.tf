resource "azurecaf_name" "caf_name_linwebapp" {
  name          = var.web_app_name
  resource_type = "azurerm_app_service"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough

  use_slug = var.global_settings.use_slug
}

resource "azurerm_linux_web_app" "this" {
  name                      = azurecaf_name.caf_name_linwebapp.result
  resource_group_name       = var.resource_group
  location                  = var.location
  https_only                = true
  service_plan_id           = var.service_plan_id
  virtual_network_subnet_id = var.appsvc_subnet_id

  identity {
    type         = var.identity.type
    identity_ids = var.identity.type == "SystemAssigned" ? [] : var.identity.identity_ids
  }

  site_config {
    vnet_route_all_enabled = true
    use_32_bit_worker      = false

    application_stack {
      docker_image     = var.webapp_options.application_stack.docker_image
      docker_image_tag = var.webapp_options.application_stack.docker_image_tag
      dotnet_version   = var.webapp_options.application_stack.dotnet_version
      java_version     = var.webapp_options.application_stack.java_version
      php_version      = var.webapp_options.application_stack.php_version
      node_version     = var.webapp_options.application_stack.node_version
    }
  }

  sticky_settings {
    app_setting_names = [
      "APPINSIGHTS_INSTRUMENTATIONKEY",
      "APPINSIGHTS_PROFILERFEATURE_VERSION",
      "APPINSIGHTS_SNAPSHOTFEATURE_VERSION",
      "APPLICATIONINSIGHTS_CONNECTION_STRING",
      "ApplicationInsightsAgent_EXTENSION_VERSION",
      "DiagnosticServices_EXTENSION_VERSION",
      "InstrumentationEngine_EXTENSION_VERSION",
      "SnapshotDebugger_EXTENSION_VERSION",
      "XDT_MicrosoftApplicationInsights_BaseExtensions",
      "XDT_MicrosoftApplicationInsights_Java",
      "XDT_MicrosoftApplicationInsights_Mode",
      "XDT_MicrosoftApplicationInsights_NodeJS",
      "XDT_MicrosoftApplicationInsights_PreemptSdk"
    ]
  }

  //ToDo: Check if this is really needed

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"                  = "${var.webapp_options.instrumentation_key}"
    "APPINSIGHTS_PROFILERFEATURE_VERSION"             = "1.0.0"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"             = "1.0.0"
    "APPLICATIONINSIGHTS_CONNECTION_STRING"           = "${var.webapp_options.ai_connection_string}"
    "ApplicationInsightsAgent_EXTENSION_VERSION"      = "~2"
    "DiagnosticServices_EXTENSION_VERSION"            = "~3"
    "InstrumentationEngine_EXTENSION_VERSION"         = "~1"
    "SnapshotDebugger_EXTENSION_VERSION"              = "~1"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" = "~1"
    "XDT_MicrosoftApplicationInsights_Java"           = "1"
    "XDT_MicrosoftApplicationInsights_Mode"           = "recommended"
    "XDT_MicrosoftApplicationInsights_NodeJS"         = "1"
    "XDT_MicrosoftApplicationInsights_PreemptSdk"     = "disabled"
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.service_plan
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name                       = "${azurerm_linux_web_app.this.name}-diagnostic-settings}"
  target_resource_id         = azurerm_linux_web_app.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  # log_analytics_destination_type = "Dedicated"

  enabled_log {
    category_group = "allLogs"

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

resource "azurecaf_name" "webapp" {
  name          = azurecaf_name.caf_name_linwebapp.result
  resource_type = "azurerm_private_endpoint"
}

module "private_endpoint" {
  source = "../../private-endpoint"

  name                           = azurecaf_name.webapp.result
  resource_group                 = var.resource_group
  location                       = var.location
  subnet_id                      = var.frontend_subnet_id
  private_connection_resource_id = azurerm_linux_web_app.this.id

  subresource_names = ["sites"]

  private_dns_zone = var.private_dns_zone

  private_dns_records = [
    lower("${azurerm_linux_web_app.this.name}"),
    lower("${azurerm_linux_web_app.this.name}.scm")
  ]
}

resource "azurerm_linux_web_app_slot" "slot" {
  name                      = var.webapp_options.slots[0]
  app_service_id            = azurerm_linux_web_app.this.id
  virtual_network_subnet_id = var.appsvc_subnet_id
  https_only                = true

  identity {
    type         = var.identity.type
    identity_ids = var.identity.type == "SystemAssigned" ? [] : var.identity.identity_ids
  }

  site_config {
    vnet_route_all_enabled = true
    use_32_bit_worker      = false

    application_stack {
      docker_image     = var.webapp_options.application_stack.docker_image
      docker_image_tag = var.webapp_options.application_stack.docker_image_tag
      dotnet_version   = var.webapp_options.application_stack.dotnet_version
      java_version     = var.webapp_options.application_stack.java_version
      php_version      = var.webapp_options.application_stack.php_version
      node_version     = var.webapp_options.application_stack.node_version
    }
  }
}

resource "azurecaf_name" "slot" {
  name          = "${azurecaf_name.caf_name_linwebapp.result}-${var.webapp_options.slots[0]}"
  resource_type = "azurerm_private_endpoint"
}

module "private_endpoint_slot" {
  source = "../../private-endpoint"

  name                           = azurecaf_name.slot.result
  resource_group                 = var.resource_group
  location                       = var.location
  subnet_id                      = var.frontend_subnet_id
  private_connection_resource_id = azurerm_linux_web_app.this.id

  subresource_names = ["sites-${var.webapp_options.slots[0]}"]

  private_dns_zone = var.private_dns_zone

  private_dns_records = [
    lower("${azurerm_linux_web_app.this.name}-${azurerm_linux_web_app_slot.slot.name}"),
    lower("${azurerm_linux_web_app.this.name}-${azurerm_linux_web_app_slot.slot.name}.scm")
  ]

  depends_on = [
    azurerm_linux_web_app_slot.slot
  ]
}