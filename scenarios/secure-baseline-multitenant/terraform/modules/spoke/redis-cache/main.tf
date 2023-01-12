terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

resource "azurecaf_name" "redis-cache" {
  name          = var.application_name
  resource_type = "azurerm_redis_cache"
  suffixes      = [var.environment, var.unique_id]
}

resource "azurerm_redis_cache" "redis-cache" {
  name                = azurecaf_name.redis-cache.result
  location            = var.location
  resource_group_name = var.resource_group
  capacity            = 2
  family              = "C"
  sku_name            = var.sku_name
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  public_network_access_enabled = false

  redis_configuration {
    enable_authentication = true
  }

  tags = {
    environment = "App Service Secure Baseline"
  } 
}

resource "azurecaf_name" "redis-cache-private-endpoint" {
  name          = azurerm_redis_cache.redis-cache.name
  resource_type = "azurerm_private_endpoint"
}

# Create a private endpoint for the Redis Cache
resource "azurerm_private_endpoint" "redis-cache-private-endpoint" {
  name                = azurecaf_name.redis-cache-private-endpoint.result
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private_link_subnet_id
  depends_on          = [azurerm_redis_cache.redis-cache]

  private_service_connection {
    name                           = "redis-cache-private-endpoint"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_redis_cache.redis-cache.id
    subresource_names              = ["redisCache"]
  }
}

resource "azurerm_private_dns_a_record" "redis-cache-private-dns" {
  name                = lower(azurerm_redis_cache.redis-cache.name)
  zone_name           = var.private_dns_zone_name
  resource_group_name = var.resource_group
  ttl                 = 300
  records             = [azurerm_private_endpoint.redis-cache-private-endpoint.private_service_connection[0].private_ip_address]
}
