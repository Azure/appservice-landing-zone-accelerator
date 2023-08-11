resource "azurecaf_name" "caf_name_sqlserver" {
  name          = var.application_name
  resource_type = "azurerm_mssql_server"
  prefixes      = var.global_settings.prefixes
  suffixes      = [var.environment, var.unique_id] #NOTE: globally unique
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough

  use_slug = var.global_settings.use_slug
}


# Create the SQL Server 
resource "azurerm_mssql_server" "this" {
  name                          = azurecaf_name.caf_name_sqlserver.result
  resource_group_name           = var.resource_group
  location                      = var.location
  version                       = "12.0"
  connection_policy             = "Default"
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"

  tags = local.tags

  azuread_administrator {
    login_username              = var.aad_admin_group_name
    object_id                   = var.aad_admin_group_object_id
    azuread_authentication_only = true
    tenant_id                   = var.tenant_id
  }
}

# Create a the SQL database 
resource "azurerm_mssql_database" "this" {
  count = length(var.sql_databases)

  server_id = azurerm_mssql_server.this.id
  name      = var.sql_databases[count.index].name
  sku_name  = var.sql_databases[count.index].sku_name
}

resource "azurecaf_name" "private_endpoint" {
  name          = azurerm_mssql_server.this.name
  resource_type = "azurerm_private_endpoint"
}

# Create a private endpoint for the SQL Server
resource "azurerm_private_endpoint" "this" {
  name                = azurecaf_name.private_endpoint.result
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private_link_subnet_id

  private_service_connection {
    name                           = azurecaf_name.private_endpoint.result
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mssql_server.this.id
    subresource_names              = ["sqlServer"]
  }
}

resource "azurerm_private_dns_a_record" "this" {
  name                = lower(azurerm_mssql_server.this.name)
  zone_name           = var.private_dns_zone.name
  resource_group_name = var.private_dns_zone.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.this.private_service_connection[0].private_ip_address]
}