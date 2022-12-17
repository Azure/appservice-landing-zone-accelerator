output "sql_server_name" {
    value = azurerm_mssql_server.sql-server.name
}

output "sql_db_name" {
    value = azurerm_mssql_database.sample-db.name
}

output "sql_db_connection_string" {
    value = "Server=tcp:${azurerm_mssql_server.sql-server.name}.database.windows.net;Authentication=Active Directory Default;Database=${azurerm_mssql_database.sample-db.name};"
}