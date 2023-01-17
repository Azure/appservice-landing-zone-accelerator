terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

locals {
  app-svc-plan-name = "asp-${var.application_name}-${var.environment}"
  web-app-name      = "app-${var.application_name}-${var.environment}-${var.unique_id}"
}

resource "azurerm_service_plan" "this" {
  name                = local.app-svc-plan-name
  resource_group_name = var.resource_group
  location            = var.location
  sku_name            = var.sku_name
  os_type             = var.os_type
}

resource "azurerm_windows_web_app" "this" {
  name                      = local.web-app-name
  resource_group_name       = var.resource_group
  location                  = var.location
  https_only                = true
  service_plan_id           = azurerm_service_plan.this.id
  virtual_network_subnet_id = var.appsvc_subnet_id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    vnet_route_all_enabled = true
    use_32_bit_worker      = false

    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v6.0"
    }
  }

  sticky_settings {
    app_setting_names = [
      "APPINSIGHTS_INSTRUMENTATIONKEY",
      "APPLICATIONINSIGHTS_CONNECTION_STRING",
    ]
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"                  = "${var.instrumentation_key}"
    "APPINSIGHTS_PROFILERFEATURE_VERSION"             = "1.0.0"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"             = "1.0.0"
    "APPLICATIONINSIGHTS_CONNECTION_STRING"           = "${var.ai_connection_string}"
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

resource "azurerm_windows_web_app_slot" "slot" {
  name                      = var.webapp_slot_name
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
      current_stack  = "dotnet"
      dotnet_version = "v6.0"
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"                  = "${var.instrumentation_key}"
    "APPINSIGHTS_PROFILERFEATURE_VERSION"             = "1.0.0"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"             = "1.0.0"
    "APPLICATIONINSIGHTS_CONNECTION_STRING"           = "${var.ai_connection_string}"
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
  name          = local.web-app-name
  resource_type = "azurerm_private_endpoint"
}

resource "azurerm_private_endpoint" "webapp" {
  name                = azurecaf_name.webapp.result
  resource_group_name = var.resource_group
  location            = var.location
  subnet_id           = var.frontend_subnet_id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone.id]
  }

  private_service_connection {
    name                           = "webapp-private-connection"
    private_connection_resource_id = azurerm_windows_web_app.this.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}

resource "azurecaf_name" "slot" {
  name          = "${local.web-app-name}-slot"
  resource_type = "azurerm_private_endpoint"
}

resource "azurerm_private_endpoint" "slot" {
  name                = azurecaf_name.slot.result
  resource_group_name = var.resource_group
  location            = var.location
  subnet_id           = var.frontend_subnet_id

  private_service_connection {
    name                           = "webapp-slot-private-connection"
    private_connection_resource_id = azurerm_windows_web_app.this.id  # Note: needs to be the resource id of the app, not the id of the slot
    subresource_names              = ["sites-${var.webapp_slot_name}"]
    is_manual_connection           = false
  }

  depends_on = [
    azurerm_windows_web_app_slot.slot
  ]
}

resource "azurerm_private_dns_a_record" "slot" {
  name                = lower("${azurerm_windows_web_app.this.name}-${azurerm_windows_web_app_slot.slot.name}")
  zone_name           = var.private_dns_zone.name
  
  resource_group_name = var.resource_group
  ttl                 = 300
  records             = [azurerm_private_endpoint.slot.private_service_connection[0].private_ip_address]
}
