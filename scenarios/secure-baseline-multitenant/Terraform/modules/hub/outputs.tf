output "rg_name" {
  value = azurerm_resource_group.hub.name
}

output "vnet_name" {
  value = module.network.vnet_name
}

output "vnet_id" {
  value = module.network.vnet_id
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

