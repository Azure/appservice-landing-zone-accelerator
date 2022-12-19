output "sql_db_connection_string" {
  value = module.spoke.sql_db_connection_string
}

output "devops_vm_rdp" {
  value = "az network bastion rdp --name ${module.hub.bastion-name} --resource-group ${module.hub.rg_name} --target-resource-id ${module.spoke.devops_vm_id} --disable-gateway"
}

output "grant_app_permissions_sql" {
  value = <<EOT
CREATE USER [${module.spoke.web_app_name}] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [${module.spoke.web_app_name}];
ALTER ROLE db_datawriter ADD MEMBER [${module.spoke.web_app_name}];
ALTER ROLE db_ddladmin ADD MEMBER [${module.spoke.web_app_name}];
GO

CREATE USER [${module.spoke.web_app_name}/slots/${module.spoke.web_app_slot_name}] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [${module.spoke.web_app_name}/slots/${module.spoke.web_app_slot_name}];
ALTER ROLE db_datawriter ADD MEMBER [${module.spoke.web_app_name}/slots/${module.spoke.web_app_slot_name}];
ALTER ROLE db_ddladmin ADD MEMBER [${module.spoke.web_app_name}/slots/${module.spoke.web_app_slot_name}];
GO
  EOT
}