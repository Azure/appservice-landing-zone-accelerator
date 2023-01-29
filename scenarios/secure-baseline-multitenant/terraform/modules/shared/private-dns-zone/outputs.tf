output "dns_zones" {
    value = azurerm_private_dns_zone.this[*]
}