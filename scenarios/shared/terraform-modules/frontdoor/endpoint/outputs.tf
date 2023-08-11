output "cdn_frontdoor_endpoint_uri" {
  value = "https://${azurerm_cdn_frontdoor_endpoint.web_app.host_name}/"
}

output "cdn_frontdoor_endpoint_id" {
  value = azurerm_cdn_frontdoor_endpoint.web_app.id
}