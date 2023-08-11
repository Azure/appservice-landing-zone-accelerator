resource "azurecaf_name" "caf_name_law" {
  count         = var.log_analytics_workspace_id == null ? 1 : 0
  name          = var.name
  resource_type = "azurerm_log_analytics_workspace"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough

  use_slug = var.global_settings.use_slug
}


resource "azurerm_log_analytics_workspace" "law" {
  count = var.log_analytics_workspace_id == null ? 1 : 0

  name                = azurecaf_name.caf_name_law.0.result
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "PerGB2018"
  # internet_ingestion_enabled = false

}