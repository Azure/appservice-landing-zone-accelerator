output "redis_kv_secret_name" {
    value = "redis_connection_string"
}

output "redis_connection_string" {
    value = azurerm_redis_cache.redis-cache.primary_connection_string
}