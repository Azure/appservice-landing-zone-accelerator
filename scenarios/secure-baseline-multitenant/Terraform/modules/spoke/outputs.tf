output "spoke_vnet_id" {
  value = module.spoke-network.vnet_id
}

output "spoke_rg_name" {
  value = azurerm_resource_group.spoke.name
}