output "sql_db_connection_string" {
  value = module.spoke.sql_db_connection_string
}

output "devops_vm_rdp" {
  value = "az network bastion rdp --name ${module.hub.bastion-name} --resource-group ${module.hub.rg_name} --target-resource-id ${module.spoke.devops_vm_id}"
}