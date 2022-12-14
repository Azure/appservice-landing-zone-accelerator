output "web_app_id" {
    value = azurerm_windows_web_app.secure-baseline-web-app.id
}

output "web_app_hostname" {
    value = azurerm_windows_web_app.secure-baseline-web-app.default_hostname
}

output "web_app_identity_principal_id" {
    value = azurerm_windows_web_app.secure-baseline-web-app.identity.0.principal_id
}