output "web_app_id" {
    value = azurerm_windows_web_app.secure-baseline-web-app.id
}

output "web_app_hostname" {
    value = azurerm_windows_web_app.secure-baseline-web-app.default_hostname
}