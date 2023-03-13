terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

resource "azurecaf_name" "app-config" {
  name          = var.application_name
  resource_type = "azurerm_app_configuration"
  suffixes      = [var.environment, var.unique_id] #NOTE: globally unique
}

resource "azurerm_app_configuration" "app-config" {
  name                       = azurecaf_name.app-config.result
  resource_group_name        = var.resource_group
  location                   = var.location
  sku                        = "standard"
  local_auth_enabled         = false
  public_network_access      = "Disabled"
  purge_protection_enabled   = false
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

  tags = {
    environment = "development"
  }

#   depends_on = [
#     azurerm_key_vault_access_policy.client,
#     azurerm_key_vault_access_policy.server,
#   ]
}

# "Server=tcp:<server-name>.database.windows.net;Authentication=Active Directory Default; Database=<database-name>;"

locals {
  sql-connectionstring = "Server=tcp:${var.sql_server_name}.database.windows.net;Authentication=Active Directory Default; Database=${var.sql_db_name};"
}

# resource "azurerm_app_configuration_key" "sql-connectionstring" {
#   configuration_store_id = azurerm_app_configuration.app-config.id
#   key                    = "sql-connectionstring"
#   label                  = var.environment
#   content_type           = "connectionstring"
#   value                  = "Server=tcp:${var.sql_server_name}.database.windows.net;Authentication=Active Directory Default; Database=${var.sql_db_name};"
# }

# Create a private endpoint for the SQL Server
resource "azurerm_private_endpoint" "appcg-private-endpoint" {
  name                = "appcg-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private_link_subnet_id

  private_service_connection {
    name                           = "app-config-private-endpoint"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_app_configuration.app-config.id
    subresource_names              = ["configurationStores"]
  }
}

# Create a private DNS A Record for the SQL Server
resource "azurerm_private_dns_a_record" "appcg-private-dns" {
  name                = lower(azurerm_app_configuration.app-config.name)
  zone_name           = var.private_dns_zone_name
  resource_group_name = var.resource_group
  ttl                 = 300
  records             = [azurerm_private_endpoint.appcg-private-endpoint.private_service_connection[0].private_ip_address]
}