terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

resource "azurecaf_name" "redis_cache" {
  name          = var.application_name
  resource_type = "azurerm_redis_cache"
  suffixes      = [var.environment, var.unique_id]
}

resource "azurerm_redis_cache" "redis_cache" {
  name                = azurecaf_name.redis_cache.result
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

resource "azurecaf_name" "redis_cache_private_endpoint" {
  name          = azurerm_redis_cache.redis_cache.name
  resource_type = "azurerm_private_endpoint"
}

# Create a private endpoint for the Redis Cache
resource "azurerm_private_endpoint" "redis_cache_private_endpoint" {
  name                = azurecaf_name.redis_cache_private_endpoint.result
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private_link_subnet_id

  private_service_connection {
    name                           = "redis-cache-private-endpoint"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_redis_cache.redis_cache.id
    subresource_names              = ["redisCache"]
  }
}

resource "azurerm_private_dns_a_record" "redis_cache_private_dns" {
  name                = lower(azurerm_redis_cache.redis_cache.name)
  zone_name           = var.private_dns_zone_name
  resource_group_name = var.resource_group
  ttl                 = 300
  records             = [azurerm_private_endpoint.redis_cache_private_endpoint.private_service_connection[0].private_ip_address]
}
