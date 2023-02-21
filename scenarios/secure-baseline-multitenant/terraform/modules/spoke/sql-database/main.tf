terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.23"
    }
  }
}

resource "azurecaf_name" "sql_server" {
  name          = var.application_name
  resource_type = "azurerm_mssql_server"
  suffixes      = [var.environment, var.unique_id] #NOTE: globally unique
}

# Create the SQL Server 
resource "azurerm_mssql_server" "this" {
  name                          = azurecaf_name.sql_server.result
  resource_group_name           = var.resource_group
  location                      = var.location
  version                       = "12.0"
  connection_policy             = "Default"
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"

  tags = {
    environment = var.environment
  }

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
  resource_group_name = var.private_dns_zone.resource_group
  ttl                 = 300
  records             = [azurerm_private_endpoint.this.private_service_connection[0].private_ip_address]
}
