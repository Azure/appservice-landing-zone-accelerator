resource "azurecaf_name" "caf_name_redis" {
  name          = var.application_name
  resource_type = "azurerm_redis_cache"
  prefixes      = var.global_settings.prefixes
  suffixes      = [var.environment, var.unique_id]
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough

  use_slug = var.global_settings.use_slug
}

resource "azurerm_redis_cache" "this" {
  name                          = azurecaf_name.caf_name_redis.result
  location                      = var.location
  resource_group_name           = var.resource_group
  capacity                      = 2
  family                        = "C"
  sku_name                      = var.sku_name
  enable_non_ssl_port           = false
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false

  redis_configuration {
    enable_authentication = true
  }

  tags = local.tags
}

resource "azurecaf_name" "private_endpoint" {
  name          = azurerm_redis_cache.this.name
  resource_type = "azurerm_private_endpoint"
}

resource "azurerm_private_endpoint" "this" {
  name                = azurecaf_name.private_endpoint.result
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private_link_subnet_id

  private_service_connection {
    name                           = azurecaf_name.private_endpoint.result
    is_manual_connection           = false
    private_connection_resource_id = azurerm_redis_cache.this.id
    subresource_names              = ["redisCache"]
  }
}

resource "azurerm_private_dns_a_record" "this" {
  name                = lower(azurerm_redis_cache.this.name)
  zone_name           = var.private_dns_zone.name
  resource_group_name = var.private_dns_zone.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.this.private_service_connection[0].private_ip_address]
}