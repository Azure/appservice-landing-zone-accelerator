output "sql_db_connection_string" {
  value = module.spoke.sql_db_connection_string
}

output "vault_uri" {
  value = module.spoke.key_vault_uri
}

output "web_app_uri" {
  value = module.spoke.web_app_uri
}

output "cmd_devops_vm_rdp" {
  value = "az network bastion rdp --name ${module.hub.bastion_name} --resource-group ${module.hub.rg_name} --target-resource-id ${module.spoke.devops_vm_id} --disable-gateway"
}

output "cmd_grant_sql_permissions" {
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

output "cmd_swap_slots" {
  value = "az webapp deployment slot swap -n ${module.spoke.web_app_name} -g ${module.spoke.rg_name} --slot ${var.webapp_slot_name} --target-slot production"
}

output "cmd_redis_connection_kvsecret" {
  value     = var.deployment_options.deploy_redis ? "az keyvault secret set --vault-name ${module.spoke.key_vault_name} --name ${module.spoke.redis_connection_secret_name} --value ${module.spoke.redis_connection_string}" : null
  sensitive = true
}