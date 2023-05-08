resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  count = length(var.vnet_links)

  name                  = var.vnet_links[count.index].vnet_resource_group
  private_dns_zone_name = var.name
  resource_group_name   = var.resource_group
  virtual_network_id    = var.vnet_links[count.index].vnet_id
}