resource "azurerm_private_dns_zone" "this" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group

  tags = local.tags
}

# Link the Private DNS Zone to the list of virtual networks
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  count = length(var.vnet_links)

  name                  = element(split("/", var.vnet_links[count.index]), length(split("/", var.vnet_links[count.index])) - 1)
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  resource_group_name   = var.resource_group
  virtual_network_id    = var.vnet_links[count.index]
}

resource "azurerm_private_dns_a_record" "this" {
  count = length(var.dns_records)

  name                = var.dns_records[count.index].dns_name
  records             = var.dns_records[count.index].records
  zone_name           = azurerm_private_dns_zone.this.name
  resource_group_name = var.resource_group
  ttl                 = 300
}
