resource "azurecaf_name" "law" {
  name          = var.application_name
  resource_type = "azurerm_log_analytics_workspace"
  suffixes      = [var.environment]
}

resource "azurecaf_name" "caf_name_law" {
  name          = var.application_name
  resource_type = "azurerm_log_analytics_workspace"
  prefixes      = local.global_settings.prefixes
  suffixes      = [var.environment]
  random_length = local.global_settings.random_length
  clean_input   = true
  passthrough   = local.global_settings.passthrough
  use_slug      = local.global_settings.use_slug
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = azurecaf_name.law.result
  location            = var.location
  resource_group_name = azurerm_resource_group.shared.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  # internet_ingestion_enabled = false

  tags = local.base_tags
}