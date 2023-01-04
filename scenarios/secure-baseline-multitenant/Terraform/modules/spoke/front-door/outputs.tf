output "web_app_endpoint_uri" {
    value = "https://${azurerm_cdn_frontdoor_endpoint.web_app.host_name}/"
}
