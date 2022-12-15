output "vnet_id" {
  value = module.spoke-network.vnet_id
}

output "vnet_name" {
  value = module.spoke-network.vnet_name
}

output "rg_name" {
  value = azurerm_resource_group.spoke.name
}