resource "azurecaf_name" "caf_name_pip" {
  name          = "${var.name}-bastion"
  resource_type = "azurerm_public_ip"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough

  use_slug = var.global_settings.use_slug
}

resource "azurecaf_name" "caf_name_bastion" {
  name          = var.name
  resource_type = "azurerm_virtual_network"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough

  use_slug = var.global_settings.use_slug
}


resource "azurerm_public_ip" "bastion_pip" {
  name                = azurecaf_name.caf_name_pip.result
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = azurecaf_name.caf_name_bastion.result
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Standard"
  tunneling_enabled   = true

  ip_configuration {
    name                 = "bastionHostIpConfiguration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }

  tags = local.tags
}
