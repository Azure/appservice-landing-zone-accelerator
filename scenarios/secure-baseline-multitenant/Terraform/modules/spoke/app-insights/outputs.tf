output "instrumentation_key" {
  value = azurerm_application_insights.web-app.instrumentation_key
}

output "connection_string" {
  value = azurerm_application_insights.web-app.connection_string
}

output "app_id" {
  value = azurerm_application_insights.web-app.app_id
}