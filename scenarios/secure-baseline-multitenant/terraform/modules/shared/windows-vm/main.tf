terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

resource "azurecaf_name" "vm" {
  name          = var.vm_name
  resource_type = "azurerm_windows_virtual_machine"
  suffixes      = [var.unique_id]
}

locals {
  vm_name = azurecaf_name.vm.result
}

resource "azurerm_network_interface" "vm_nic" {
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
  name                       = local.vm_name
  resource_group_name        = var.resource_group
  location                   = var.location
  size                       = var.vm_size
  admin_username             = var.admin_username
  admin_password             = var.admin_password
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
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }
}

data "azuread_user" "vm_admin" {
  user_principal_name = var.aad_admin_username
}

resource "azurerm_role_assignment" "vm_admin_role_assignment" {
  scope                = azurerm_windows_virtual_machine.vm.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = data.azuread_user.vm_admin.object_id
}

resource "azurerm_virtual_machine_extension" "aad" {
  count = var.enable_azure_ad_join ? 1 : 0

  name                       = "aad-login-for-windows"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id

  settings = !var.enroll_with_mdm ? null : <<SETTINGS
    {
      "mdmId": "${var.mdm_id}"
    }
  SETTINGS

  timeouts {
    create = "60m"
  }

  depends_on = [
    var.firewall_rules
  ]
}

resource "azurerm_virtual_machine_extension" "install_sql" {
  count = var.install_extensions ? 1 : 0

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

  timeouts {
    create = "60m"
  }

  depends_on = [
    var.firewall_rules
  ]
}
