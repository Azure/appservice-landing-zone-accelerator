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
  value = length(module.sql_database) > 0 ? module.sql_database[0].sql_db_connection_string : null
}

output "devops_vm_id" {
  value = length(module.devops_vm) > 0 ? module.devops_vm[0].id : null
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
  value = module.front_door.frontdoor_endpoint_uris
}

output "redis_connection_secret_name" {
  value = length(module.redis_cache) > 0 ? module.redis_cache[0].redis_kv_secret_name : null
}

output "redis_connection_string" {
  value     = length(module.redis_cache) > 0 ? module.redis_cache[0].redis_connection_string : null
  sensitive = true
}

output "key_vault_name" {
  value = module.key_vault.vault_name
}