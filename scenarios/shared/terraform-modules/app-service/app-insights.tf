resource "azurecaf_name" "caf_name_appinsights" {
  name          = var.application_name
  resource_type = "azurerm_application_insights"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  suffixes      = var.global_settings.suffixes

  use_slug = var.global_settings.use_slug
}


resource "azurerm_application_insights" "this" {
  name                          = azurecaf_name.caf_name_appinsights.result
  location                      = var.location
  resource_group_name           = var.resource_group
  workspace_id                  = var.log_analytics_workspace_id
  application_type              = "web"
  local_authentication_disabled = false
  internet_ingestion_enabled    = true
}