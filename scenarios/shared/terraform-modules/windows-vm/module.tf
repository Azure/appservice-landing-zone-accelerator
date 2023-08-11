resource "azurecaf_name" "caf_name_winvm" {
  name          = var.vm_name
  resource_type = "azurerm_windows_virtual_machine"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough

  use_slug = var.global_settings.use_slug
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "${var.vm_name}-ipconfig"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Generate password if none provided
resource "random_password" "password" {
  count            = var.admin_password == null ? 1 : 0
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  admin_password = var.admin_password == null ? random_password.password[0].result : var.admin_password
}

resource "azurerm_key_vault_secret" "admin_password" {
  count        = var.key_vault_id == null ? 0 : 1
  name         = azurerm_windows_virtual_machine.vm.name
  value        = local.admin_password
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "admin_username" {
  count        = var.key_vault_id == null ? 0 : 1
  name         = azurerm_windows_virtual_machine.vm.name
  value        = var.admin_username
  key_vault_id = var.key_vault_id
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                       = azurecaf_name.caf_name_winvm.result
  resource_group_name        = var.resource_group
  location                   = var.location
  size                       = var.vm_size
  admin_username             = var.admin_username
  admin_password             = local.admin_password
  provision_vm_agent         = true
  allow_extension_operations = true

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type         = var.identity.type
    identity_ids = var.identity.type == "SystemAssigned" ? [] : var.identity.identity_ids
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  tags = local.tags
  # provisioner "remote-exec" {
  #   inline = var.remote_exec_commands
  # }
}

data "azuread_user" "vm_admin" {
  count = var.aad_admin_object_id != null ? 0 : 1

  user_principal_name = var.aad_admin_username
}

resource "azurerm_role_assignment" "vm_admin_role_assignment" {
  scope                = azurerm_windows_virtual_machine.vm.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = var.aad_admin_object_id != null ? var.aad_admin_object_id : data.azuread_user.vm_admin[0].object_id
}