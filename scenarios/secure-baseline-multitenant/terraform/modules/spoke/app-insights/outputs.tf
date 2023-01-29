output "instrumentation_key" {
  value = azurerm_application_insights.web_app.instrumentation_key
}

output "connection_string" {
  value = azurerm_application_insights.web_app.connection_string
}

output "app_id" {
  value = azurerm_application_insights.web_app.app_id
}