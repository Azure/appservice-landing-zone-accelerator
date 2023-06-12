output "redis_kv_secret_name" {
  value = "redis-connection-string"
}

output "redis_connection_string" {
  value = azurerm_redis_cache.this.primary_connection_string
}