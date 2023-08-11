resource "azurecaf_name" "route_table" {
  name          = var.route_table_name
  resource_type = "azurerm_route_table"
}

resource "azurerm_route_table" "this" {
  name                          = azurecaf_name.route_table.result
  location                      = var.location
  resource_group_name           = var.resource_group
  disable_bgp_route_propagation = false

  tags = local.tags
}

resource "azurerm_route" "this" {
  count = length(var.routes)

  name                   = var.routes[count.index].name
  resource_group_name    = var.resource_group
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = var.routes[count.index].address_prefix
  next_hop_type          = var.routes[count.index].next_hop_type
  next_hop_in_ip_address = var.routes[count.index].next_hop_in_ip_address
}

resource "azurerm_subnet_route_table_association" "this" {
  count = length(var.subnet_ids)

  subnet_id      = var.subnet_ids[count.index]
  route_table_id = azurerm_route_table.this.id
}
