resource "azurerm_virtual_network_peering" "target_to_this" {
  name                         = "hub-to-spoke-${var.application_name}"
  resource_group_name          = var.hub_settings.rg_name
  virtual_network_name         = var.hub_settings.vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.this.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "this_to_target" {
  name                         = "spoke-to-hub-${var.application_name}"
  resource_group_name          = azurerm_resource_group.spoke.name
  virtual_network_name         = module.network.vnet_name
  remote_virtual_network_id    = data.azurerm_virtual_network.target.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}