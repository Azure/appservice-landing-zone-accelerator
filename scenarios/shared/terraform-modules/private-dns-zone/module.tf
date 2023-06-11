resource "azurerm_private_dns_zone" "this" {
  count = length(var.dns_zones)

  name                = var.dns_zones[count.index]
  resource_group_name = var.resource_group

  tags = local.tags
}

# Link the Private DNS Zone to the list of virtual networks
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  count = length(var.vnet_links)

  name                  = azurerm_private_dns_zone.this[count.index].name
  private_dns_zone_name = azurerm_private_dns_zone.this[count.index].name
  resource_group_name   = var.resource_group
  virtual_network_id    = var.vnet_links[count.index].vnet_id
}