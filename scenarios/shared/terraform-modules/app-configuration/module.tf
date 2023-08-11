resource "azurecaf_name" "caf_name_appconf" {
  name          = var.application_name
  resource_type = "azurerm_app_configuration"
  prefixes      = var.global_settings.prefixes
  suffixes      = [var.environment, var.unique_id] #NOTE: globally unique
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough

  use_slug = var.global_settings.use_slug
}

resource "azurerm_app_configuration" "this" {
  name                       = azurecaf_name.caf_name_appconf.result
  resource_group_name        = var.resource_group
  location                   = var.location
  sku                        = "standard"
  local_auth_enabled         = false
  public_network_access      = "Disabled"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  #   identity {
  #     type = "UserAssigned"
  #     identity_ids = [
  #       azurerm_user_assigned_identity.example.id,
  #     ]
  #   }

  #   encryption {
  #     key_vault_key_identifier = azurerm_key_vault_key.example.id
  #     identity_client_id       = azurerm_user_assigned_identity.example.client_id
  #   }

  tags = local.tags
}

resource "azurecaf_name" "private_endpoint" {
  name          = azurerm_app_configuration.this.name
  resource_type = "azurerm_private_endpoint"
}

# Create a private endpoint for the SQL Server
resource "azurerm_private_endpoint" "this" {
  name                = azurecaf_name.private_endpoint.result
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private_link_subnet_id

  private_service_connection {
    name                           = "app-config-private-endpoint"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_app_configuration.this.id
    subresource_names              = ["configurationStores"]
  }
}

resource "azurerm_role_assignment" "data_readers" {
  count = length(var.data_reader_identities)

  scope                = azurerm_app_configuration.this.id
  role_definition_name = "App Configuration Data Reader"
  principal_id         = var.data_reader_identities[count.index]
}

resource "azurerm_role_assignment" "data_owners" {
  count = length(var.data_owner_identities)

  scope                = azurerm_app_configuration.this.id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = var.data_owner_identities[count.index]
}

resource "azurerm_private_dns_a_record" "this" {
  name                = lower(azurerm_app_configuration.this.name)
  zone_name           = var.private_dns_zone.name
  resource_group_name = var.private_dns_zone.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.this.private_service_connection[0].private_ip_address]
}