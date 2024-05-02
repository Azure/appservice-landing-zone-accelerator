
resource "azurerm_private_endpoint" "this" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = var.name
    private_connection_resource_id = var.private_connection_resource_id

    subresource_names    = length(var.subresource_names) == 0 ? null : var.subresource_names
    is_manual_connection = false
  }

  tags = local.tags
}

resource "azurerm_private_dns_a_record" "this" {
  count = length(var.private_dns_records)

  name                = var.private_dns_records[count.index]
  zone_name           = var.private_dns_zone.name
  resource_group_name = var.private_dns_zone.resource_group_name
  ttl                 = var.ttl
  records             = [azurerm_private_endpoint.this.private_service_connection[0].private_ip_address]

  tags = local.tags
}