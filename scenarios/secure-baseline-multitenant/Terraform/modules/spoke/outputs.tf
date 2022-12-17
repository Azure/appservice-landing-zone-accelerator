output "vnet_id" {
  value = module.spoke-network.vnet_id
}

output "vnet_name" {
  value = module.spoke-network.vnet_name
}

output "rg_name" {
  value = azurerm_resource_group.spoke.name
}

output "sql_db_connection_string" {
  value = module.sql-database.sql_db_connection_string
}

output "devops_vm_id" {
  value = module.devops-vm.id
}