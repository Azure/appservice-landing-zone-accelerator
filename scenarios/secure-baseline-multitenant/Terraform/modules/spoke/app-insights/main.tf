terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

resource "azurecaf_name" "law" {
  name          = var.application_name
  resource_type = "azurerm_log_analytics_workspace"
  suffixes      = [var.environment]
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = azurecaf_name.law.result
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurecaf_name" "app-insights" {
  name          = var.application_name
  resource_type = "azurerm_application_insights"
  suffixes      = [var.environment]
}

resource "azurerm_application_insights" "web-app" {
  name                = azurecaf_name.app-insights.result
  location            = var.location
  resource_group_name = var.resource_group
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "web"
}