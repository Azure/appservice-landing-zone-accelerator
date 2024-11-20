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

output "web_app_slot_ids" {
  value = azurerm_windows_web_app_slot.slot.*.id
}

output "web_app_slot_names" {
  value = azurerm_windows_web_app_slot.slot.*.name
}

output "web_app_slot_hostnames" {
  value = azurerm_windows_web_app_slot.slot.*.default_hostname
}

output "web_app_slot_identities" {
  value = azurerm_windows_web_app_slot.slot.*.identity
}