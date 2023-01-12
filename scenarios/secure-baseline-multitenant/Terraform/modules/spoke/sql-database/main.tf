terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}


resource "azurecaf_name" "sql_server" {
  name          = var.application_name
  resource_type = "azurerm_mssql_server"
  suffixes      = [var.environment, var.unique_id] #NOTE: globally unique
}

# Create the SQL Server 
resource "azurerm_mssql_server" "sql_server" {
  name                          = azurecaf_name.sql_server.result
  resource_group_name           = var.resource_group
  location                      = var.location
  version                       = "12.0"
  connection_policy             = "Default"
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"

  tags = {
    environment = "App Service Secure Baseline"
  }

  azuread_administrator {
    login_username              = var.aad_admin_group_name
    object_id                   = var.aad_admin_group_object_id
    azuread_authentication_only = true # this is changed after the SQL Server is configured with the managed identity: az sql server ad-only-auth enable
    tenant_id                   = var.tenant_id
  }
}

# Create a the SQL database 
resource "azurerm_mssql_database" "sample_db" {
  name      = var.sql_db_name
  server_id = azurerm_mssql_server.sql_server.id
  sku_name  = "S0"
}

resource "azurecaf_name" "sql_server_pe" {
  name          = azurerm_mssql_server.sql_server.name
  resource_type = "azurerm_private_endpoint"
}

# Create a private endpoint for the SQL Server
resource "azurerm_private_endpoint" "sql_server_pe" {
  name                = azurecaf_name.sql_server_pe.result
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private-link-subnet-id

  private_service_connection {
    name                           = "sql-private-endpoint"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
  }
}

# Create a private DNS A Record for the SQL Server
resource "azurerm_private_dns_a_record" "sql_private_dns" {
  name                = lower(azurerm_mssql_server.sql_server.name)
  zone_name           = var.private_dns_zone_name
  resource_group_name = var.resource_group
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_server_pe.private_service_connection[0].private_ip_address]
}
