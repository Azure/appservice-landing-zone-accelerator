resource "azurerm_virtual_network_peering" "target_to_this" {
  count = var.peering_vnet != null ? 1 : 0

  name                         = "hub-to-spoke-${var.name}"
  resource_group_name          = var.peering_vnet.resource_group
  virtual_network_name         = var.peering_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.this.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "this_to_target" {
  count = var.peering_vnet != null ? 1 : 0

  name                         = "spoke-to-hub-${var.name}"
  resource_group_name          = var.resource_group
  virtual_network_name         = azurerm_virtual_network.this.name
  remote_virtual_network_id    = var.peering_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}