resource "azurerm_private_dns_zone" "this" {
  count = length(var.dns_zones)

  name                = var.dns_zones[count.index]
  resource_group_name = var.resource_group
}

# Link the Private DNS Zone to the list of virtual networks
module "private_dns_zone_vnet_link" {
  count = length(var.dns_zones)

  source = "./dns-zone-vnet-link"

  name           = azurerm_private_dns_zone.this[count.index].name
  resource_group = var.resource_group
  vnet_links     = var.vnet_links
}
