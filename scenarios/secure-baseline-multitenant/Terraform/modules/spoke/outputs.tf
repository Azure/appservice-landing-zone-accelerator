output "vnet_id" {
  value = module.spoke_network.vnet_id
}

output "vnet_name" {
  value = module.spoke_network.vnet_name
}

output "rg_name" {
  value = azurerm_resource_group.spoke.name
}

output "sql_db_connection_string" {
  value = module.sql_database.sql_db_connection_string
}

output "devops_vm_id" {
  value = module.devops_vm.id
}

output "web_app_name" {
  value = module.app_service.web_app_name
}

output "web_app_slot_name" {
  value = module.app_service.web_app_slot_name
}

output "key_vault_uri" {
    value = module.key_vault.vault_uri
}

output "web_app_uri" {
  value = module.front_door.web_app_endpoint_uri
}