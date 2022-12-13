terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

resource "random_integer" "sql-unique-id" {
  min = 1000
  max = 9999
}

resource "azurecaf_name" "sql-server" {
  name          = var.application_name
  resource_type = "azurerm_mssql_server"
  suffixes      = [var.environment, random_integer.sql-unique-id.id] #NOTE: globally unique
}

# Create the SQL Server 
resource "azurerm_mssql_server" "sql-server" {
  name                          = azurecaf_name.sql-server.result
  resource_group_name           = var.resource_group
  location                      = var.location
  version                       = "12.0"
  connection_policy             = "Default"
  public_network_access_enabled = false # this is changed after the SQL Server is configured with the managed identity: az sql server update --enable-public-network false 

  tags = {
    environment = "App Service Secure Baseline"
  }

  azuread_administrator {
    login_username              = var.sql_admin_group_name
    object_id                   = var.sql_admin_group_object_id
    azuread_authentication_only = true # this is changed after the SQL Server is configured with the managed identity: az sql server ad-only-auth enable
    tenant_id                   = var.tenant_id
  }
}

# Create a the SQL database 
resource "azurerm_mssql_database" "sample-db" {
  name      = var.sql_db_name
  server_id = azurerm_mssql_server.sql-server.id
  sku_name  = "S0"
}

# Create a private endpoint for the SQL Server
resource "azurerm_private_endpoint" "sql-private-endpoint" {
  name                = "sql-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private-link-subnet-id

  private_service_connection {
    name                           = "sql-private-endpoint"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mssql_server.sql-server.id
    subresource_names              = ["sqlServer"]
  }
}

# Create a private DNS A Record for the SQL Server
resource "azurerm_private_dns_a_record" "sql-private-dns" {
  name                = lower(azurerm_mssql_server.sql-server.name)
  zone_name           = var.sqldb_private_dns_zone_name
  resource_group_name = var.resource_group
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql-private-endpoint.private_service_connection[0].private_ip_address]
}

# locals {
#   sql_server_fqdn       = "${azurerm_private_dns_a_record.sql-private-dns.name}.database.windows.net"
#   sql_server_db         = azurerm_mssql_database.sample-db.name
#   managed_identity_name = "aks-workload-identity"
# }

# resource "azurerm_user_assigned_identity" "app_managed_identity" {
#   name                = local.managed_identity_name
#   resource_group_name = var.aks_rg_name
#   location            = var.region

#   # ./scripts/create-db-user.sh mssql-server-5728.database.windows.net 14bfade6-7c80-49d8-849f-1b16c4a0ecef northwind-db

#   provisioner "local-exec" {
#     command     = "./scripts/create-db-user.sh ${local.sql_server_fqdn} ${local.managed_identity_name} ${local.sql_server_db} ${random_string.sql-admin-username.result} ${random_password.sql-admin-password.result}"
#     working_dir = path.module
#     when        = create
#   }

#   # provisioner "local-exec-2" {
#   #   command    = ""
#   #   depends_on = [provisioner.local-exec]
#   # }

#   depends_on = [
#     azurerm_mssql_database.sample-sql-db,
#     azurerm_mssql_firewall_rule.deployment-ip
#   ]
# }
