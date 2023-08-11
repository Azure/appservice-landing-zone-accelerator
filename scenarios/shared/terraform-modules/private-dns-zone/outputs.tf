output "dns_zone" {
  value = azurerm_private_dns_zone.this
}

output "name" {
  value = azurerm_private_dns_zone.this.name
}

output "id" {
  value = azurerm_private_dns_zone.this.id
}

output "resource_group_name" {
  value = azurerm_private_dns_zone.this.resource_group_name
}