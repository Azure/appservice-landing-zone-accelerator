output "rg_name" {
  value = azurerm_resource_group.hub.name
}

output "vnet_name" {
  value = azurerm_virtual_network.hub_vnet.name
}

output "vnet_id" {
  value = azurerm_virtual_network.hub_vnet.id
}