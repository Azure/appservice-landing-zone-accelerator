output "vnet_id" {
  value = module.network.vnet_id
}

output "vnet_name" {
  value = module.network.vnet_name
}

output "rg_name" {
  value = azurerm_resource_group.spoke.name
}

output "sql_db_connection_string" {
  value = var.deployment_options.deploy_sql_database ? module.sql_database[0].sql_db_connection_string : null
}

output "devops_vm_id" {
  value = var.deployment_options.deploy_vm ? module.devops_vm[0].id : null
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

output "key_vault_name" {
  value = module.key_vault.vault_name
}

output "web_app_uri" {
  value = module.frontdoor.frontdoor_endpoint_uris
}

output "redis_connection_string" {
  value     = var.deployment_options.deploy_redis ? module.redis_cache[0].redis_connection_string : null
  sensitive = true
}