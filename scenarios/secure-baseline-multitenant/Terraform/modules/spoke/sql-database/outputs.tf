output "sql_server_name" {
    value = azurerm_mssql_server.sql_server.name
}

output "sql_db_name" {
    value = azurerm_mssql_database.sample_db.name
}

output "sql_db_connection_string" {
    value = "Server=tcp:${azurerm_mssql_server.sql_server.name}.database.windows.net;Authentication=Active Directory Default;Database=${azurerm_mssql_database.sample_db.name};"
}