output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "subnets" {
  value = { for subnet in azurerm_subnet.this : subnet.name => subnet }
}

output "subnet_ids" {
  value = [for subnet in azurerm_subnet.this : subnet.id]
}

output "vnet" {
  value = azurerm_virtual_network.this
}