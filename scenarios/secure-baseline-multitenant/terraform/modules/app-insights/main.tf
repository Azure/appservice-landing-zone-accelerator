terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.23"
    }
  }
}

resource "azurecaf_name" "app_insights" {
  name          = var.application_name
  resource_type = "azurerm_application_insights"
  suffixes      = [var.environment]
}

resource "azurerm_application_insights" "this" {
  name                          = azurecaf_name.app_insights.result
  location                      = var.location
  resource_group_name           = var.resource_group
  workspace_id                  = var.log_analytics_workspace_id
  application_type              = "web"
  local_authentication_disabled = false
  internet_ingestion_enabled    = true
}
