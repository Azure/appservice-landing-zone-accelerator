output "web_app_id" {
  value = azurerm_linux_web_app.this.id
}

output "web_app_name" {
  value = azurerm_linux_web_app.this.name
}

output "web_app_hostname" {
  value = azurerm_linux_web_app.this.default_hostname
}

output "web_app_principal_id" {
  value = azurerm_linux_web_app.this.identity.0.principal_id
}

output "web_app_slot_id" {
  value = azurerm_linux_web_app_slot.slot.id
}

output "web_app_slot_name" {
  value = azurerm_linux_web_app_slot.slot.name
}

output "web_app_slot_hostname" {
  value = azurerm_linux_web_app_slot.slot.default_hostname
}

output "web_app_slot_principal_id" {
  value = azurerm_linux_web_app_slot.slot.identity.0.principal_id
}