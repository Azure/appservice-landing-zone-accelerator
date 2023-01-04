output "web_app_id" {
    value = azurerm_windows_web_app.secure-baseline-web-app.id
}

output "web_app_hostname" {
    value = azurerm_windows_web_app.secure-baseline-web-app.default_hostname
}

output "web_app_principal_id" {
    value = azurerm_windows_web_app.secure-baseline-web-app.identity.0.principal_id
}

output "web_app_name" {
    value = azurerm_windows_web_app.secure-baseline-web-app.name
}

output "web_app_slot_name" {
    value = azurerm_windows_web_app_slot.staging.name
}

output "web_app_slot_id" {
    value = azurerm_windows_web_app_slot.staging.id
}

output "web_app_slot_hostname" {
    value = azurerm_windows_web_app_slot.staging.default_hostname
}

output "web_app_slot_principal_id" {
    value = azurerm_windows_web_app_slot.staging.identity.0.principal_id
}