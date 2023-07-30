resource "azurecaf_name" "caf_name_id_reader" {
  name          = var.application_name
  resource_type = "azurerm_user_assigned_identity"
  prefixes      = local.global_settings.prefixes
  suffixes      = ["reader"]
  random_length = local.global_settings.random_length
  clean_input   = true
  passthrough   = local.global_settings.passthrough
  use_slug      = local.global_settings.use_slug
}

resource "azurecaf_name" "caf_name_id_contributor" {
  name          = var.application_name
  resource_type = "azurerm_user_assigned_identity"
  prefixes      = local.global_settings.prefixes
  suffixes      = ["contributor"]
  random_length = local.global_settings.random_length
  clean_input   = true
  passthrough   = local.global_settings.passthrough
  use_slug      = local.global_settings.use_slug
}

resource "azurerm_user_assigned_identity" "reader" {
  location            = azurerm_resource_group.spoke.location
  name                = azurecaf_name.caf_name_id_reader.result
  resource_group_name = azurerm_resource_group.spoke.name
}

resource "azurerm_user_assigned_identity" "contributor" {
  location            = azurerm_resource_group.spoke.location
  name                = azurecaf_name.caf_name_id_contributor.result
  resource_group_name = azurerm_resource_group.spoke.name
}
