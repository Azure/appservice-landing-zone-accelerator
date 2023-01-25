output "rg_name" {
  value = azurerm_resource_group.hub.name
}

output "vnet_name" {
  value = azurerm_virtual_network.hub_vnet.name
}

output "vnet_id" {
  value = azurerm_virtual_network.hub_vnet.id
}

output "bastion_name" {
  value = module.bastion.name
}

output "firewall_private_ip" {
  # the 0 index for the module is needed as the module is a count
  value = var.deploy_firewall ? module.firewall[0].private_ip_address : null
}

output "firewall_rules" {
  value = var.deploy_firewall ? module.firewall[0].firewall_rules : null
}

