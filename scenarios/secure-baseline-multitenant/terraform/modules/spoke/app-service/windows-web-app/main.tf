terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.23"
    }
  }
}

resource "azurerm_windows_web_app" "this" {
  name                      = var.web_app_name
  resource_group_name       = var.resource_group
  location                  = var.location
  https_only                = true
  service_plan_id           = var.service_plan_id
  virtual_network_subnet_id = var.appsvc_subnet_id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    vnet_route_all_enabled = true
    use_32_bit_worker      = false

    application_stack {
      current_stack  = coalesce(var.webapp_options.application_stack.current_stack, "dotnet")
      dotnet_version = coalesce(var.webapp_options.application_stack.dotnet_version, "v6.0")
      java_version   = coalesce(var.webapp_options.application_stack.java_version, "17")
      php_version    = coalesce(var.webapp_options.application_stack.php_version, "Off") #"Off" is the latest version available
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
}

resource "azurecaf_name" "webapp" {
  name          = var.web_app_name
  resource_type = "azurerm_private_endpoint"
}

module "private_endpoint" {
  source                         = "../../../shared/private-endpoint"

  name                           = azurecaf_name.webapp.result
  resource_group                 = var.resource_group
  location                       = var.location
  subnet_id                      = var.frontend_subnet_id
  private_connection_resource_id = azurerm_windows_web_app.this.id

  subresource_names = ["sites"]

  private_dns_zone = var.private_dns_zone

  private_dns_records = [
    lower("${azurerm_windows_web_app.this.name}"),
    lower("${azurerm_windows_web_app.this.name}.scm")
  ]
}

resource "azurerm_windows_web_app_slot" "slot" {
  name                      = var.webapp_options.slot_name
  app_service_id            = azurerm_windows_web_app.this.id
  virtual_network_subnet_id = var.appsvc_subnet_id
  https_only                = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    vnet_route_all_enabled = true
    use_32_bit_worker      = false

    application_stack {
      current_stack  = coalesce(var.webapp_options.application_stack.current_stack, "dotnet")
      dotnet_version = coalesce(var.webapp_options.application_stack.dotnet_version, "v6.0")
      java_version   = coalesce(var.webapp_options.application_stack.java_version, "17")
      php_version    = coalesce(var.webapp_options.application_stack.php_version, "Off") #"Off" is the latest version available
    }
  }
}

resource "azurecaf_name" "slot" {
  name          = "${var.web_app_name}-${var.webapp_options.slot_name}"
  resource_type = "azurerm_private_endpoint"
}

module "private_endpoint_slot" {
  source                         = "../../../shared/private-endpoint"

  name                           = azurecaf_name.slot.result
  resource_group                 = var.resource_group
  location                       = var.location
  subnet_id                      = var.frontend_subnet_id
  private_connection_resource_id = azurerm_windows_web_app.this.id

  subresource_names = ["sites-${var.webapp_options.slot_name}"]

  private_dns_zone = var.private_dns_zone

  private_dns_records = [
    lower("${azurerm_windows_web_app.this.name}-${azurerm_windows_web_app_slot.slot.name}"),
    lower("${azurerm_windows_web_app.this.name}-${azurerm_windows_web_app_slot.slot.name}.scm")
  ]

  depends_on = [
    azurerm_windows_web_app_slot.slot
  ]
}