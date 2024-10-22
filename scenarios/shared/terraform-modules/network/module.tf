resource "azurecaf_name" "caf_name_vnet" {
  name          = var.name
  resource_type = "azurerm_virtual_network"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough

  use_slug = var.global_settings.use_slug
}

resource "azurerm_virtual_network" "this" {
  name                = azurecaf_name.caf_name_vnet.result
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = var.vnet_cidr

  tags = local.tags
}

resource "azurerm_subnet" "this" {
  for_each = { for idx, subnet in var.subnets : subnet.name => subnet if subnet != null }

  name                 = each.key
  address_prefixes     = each.value.subnet_cidr
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.this.name


  dynamic "delegation" {
    for_each = each.value.delegation == null ? [] : [each.value.delegation]

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}
