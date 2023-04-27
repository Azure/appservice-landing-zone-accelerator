
#create the network interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.vmname}-nic"
  location            = var.location
  resource_group_name = var.resourceGroupName

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.cidr
    private_ip_address_allocation = "Dynamic"
  }
}

#create the vm
resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.vmname
  resource_group_name = var.resourceGroupName
  location            = var.location
  size                = "Standard_F2"
  admin_username      = var.adminUserName
  admin_password      = var.adminPassword
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  provision_vm_agent         = true
  allow_extension_operations = true
}

resource "azurerm_virtual_machine_extension" "installagent" {
  count                = var.installDevOpsAgent ? 1 : 0
  name                 = "installagent"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"


  #protected_settings = <<PROTECTED_SETTINGS
  #  {
  #    "commandToExecute": "powershell.exe -Command \"./agentsetup.ps1; exit 0;\""
  #  }
  #PROTECTED_SETTINGS

  #"commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File agentsetup.ps1 -Command \"./agentsetup.ps1; exit 0;\"",

  # !!!!! Hardcoded installagent URI does not exist anymore !!!!!
  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File agentsetup.ps1 ",
        "fileUris": ["https://github.com/Azure/appservice-landing-zone-accelerator/raw/main/shared/agentsetup.ps1"]
    }
  PROTECTED_SETTINGS
}
