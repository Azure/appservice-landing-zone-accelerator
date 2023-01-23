output "web_app_id" {
    value = azurerm_windows_web_app.this.id
}

output "web_app_name" {
    value = azurerm_windows_web_app.this.name
}

output "web_app_hostname" {
    value = azurerm_windows_web_app.this.default_hostname
}

output "web_app_principal_id" {
    value = azurerm_windows_web_app.this.identity.0.principal_id
}

output "private_endpoints" {
  value = tolist(
    [
      {
        name       = lower("${azurerm_windows_web_app.this.name}")
        ip_address = azurerm_private_endpoint.webapp.private_service_connection[0].private_ip_address
      },
      {
          name = lower("${azurerm_windows_web_app.this.name}.scm")
          ip_address = azurerm_private_endpoint.webapp.private_service_connection[0].private_ip_address
      },
      {
          name = lower("${azurerm_windows_web_app.this.name}-${azurerm_windows_web_app_slot.slot.name}")
          ip_address = azurerm_private_endpoint.slot.private_service_connection[0].private_ip_address
      },
      {
          name = lower("${azurerm_windows_web_app.this.name}-${azurerm_windows_web_app_slot.slot.name}.scm")
          ip_address = azurerm_private_endpoint.slot.private_service_connection[0].private_ip_address
      },
    ]
  )
}

output "web_app_slot_id" {
    value = azurerm_windows_web_app_slot.slot.id
}

output "web_app_slot_name" {
    value = azurerm_windows_web_app_slot.slot.name
}

output "web_app_slot_hostname" {
    value = azurerm_windows_web_app_slot.slot.default_hostname
}

output "web_app_slot_principal_id" {
    value = azurerm_windows_web_app_slot.slot.identity.0.principal_id
}