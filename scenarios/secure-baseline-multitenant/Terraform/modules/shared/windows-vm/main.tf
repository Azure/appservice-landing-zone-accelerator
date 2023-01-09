locals {
  vm_name = "${var.vm_name}-${var.unique_id}"
}

resource "azurerm_network_interface" "vm-nic" {
  name                = "${local.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "${var.vm_name}-vm-ipconfig"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = local.vm_name
  resource_group_name = var.resource_group
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.vm-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-22h2-pro"
    version   = "latest"
  }

  provision_vm_agent         = true
  allow_extension_operations = true
}

data "azuread_user" "vm-admin" {
  user_principal_name = var.aad_admin_username
}

resource "azurerm_role_assignment" "vm-admins" {
  scope                = azurerm_windows_virtual_machine.vm.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = data.azuread_user.vm-admin.object_id
}

resource "azurerm_virtual_machine_extension" "aad" {
  name                       = "aad-login-for-windows"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id

  settings = !var.enroll_with_mdm ? null : <<SETTINGS
    {
      "mdmId": "0000000a-0000-0000-c000-000000000000"
    }
  SETTINGS
}

resource "azurerm_virtual_machine_extension" "install-sql" {
  count                = var.install_extensions ? 1 : 0
  name                 = "install-ssms"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ssms-setup.ps1",
        "fileUris": ["https://raw.githubusercontent.com/Azure/appservice-landing-zone-accelerator/feature/secure-baseline-scenario/scenarios/secure-baseline-multitenant/Terraform/modules/shared/windows-vm/ssms-setup.ps1"]
    }
  PROTECTED_SETTINGS
}
