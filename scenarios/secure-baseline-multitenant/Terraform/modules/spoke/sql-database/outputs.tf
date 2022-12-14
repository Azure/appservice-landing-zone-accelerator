output "sql_server_name" {
    value = azurerm_mssql_server.sql-server.name
}

output "sql_db_name" {
    value = azurerm_mssql_database.sample-db.name
}