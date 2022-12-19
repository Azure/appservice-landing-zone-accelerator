
#create the network interface
resource "azurerm_network_interface" "vm-nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "${var.vm_name}-vm-ipconfig"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

#create the vm
resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.vm_name
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
  user_principal_name = "daniem@microsoft.com"
}

resource "azurerm_role_assignment" "vm-admins" {
  scope                = azurerm_windows_virtual_machine.vm.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = data.azuread_user.vm-admin.object_id
}

# resource "azapi_resource" "policy" {
#   name      = "iot-edge-just-in-time-policy"
#   parent_id = "${var.resource_group_id}/providers/Microsoft.Security/locations/${var.location}"
#   type      = "Microsoft.Security/locations/jitNetworkAccessPolicies@2020-01-01"
#   schema_validation_enabled = false
#   body = jsonencode({
#     "kind": "Basic"
#     "properties": {
#       "virtualMachines":  [{
#         "id": "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Compute/virtualMachines/${var.edge_vm_name}",
#         "ports": [
#           {
#             "number": 33899,
#             "protocol": "TCP",
#             "allowedSourceAddressPrefix": "10.0.0.0/8",
#             "maxRequestAccessDuration": "PT3H"
#           }
#         ]
#       }]
#     }
#   })
# }

resource "azurerm_virtual_machine_extension" "aad" {
  name                       = "aad-login-for-windows"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id

  # settings = <<SETTINGS
  #   {
  #     "mdmId": "${azurerm_windows_virtual_machine.vm.identity.0.principal_id}"
  #   }
  # SETTINGS
}

# resource "azurerm_virtual_machine_extension" "installagent" {
#   count                = var.install_extensions ? 1 : 0
#   name                 = "installagent"
#   virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.10"


#   #protected_settings = <<PROTECTED_SETTINGS
#   #  {
#   #    "commandToExecute": "powershell.exe -Command \"./agentsetup.ps1; exit 0;\""
#   #  }
#   #PROTECTED_SETTINGS

#   # https://raw.githubusercontent.com/Azure/ARO-Landing-Zone-Accelerator/main/deployment/CLI/03%20vm/start_script.ps1

#   #"commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File agentsetup.ps1 -Command \"./agentsetup.ps1; exit 0;\"",
#   protected_settings = <<PROTECTED_SETTINGS
#     {
#         "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File agentsetup.ps1 ",
#         "fileUris": ["https://raw.githubusercontent.com/cykreng/Enterprise-Scale-AppService/main/reference-implementations/LOB-ILB-ASEv3/bicep/shared/agentsetup.ps1"]
#     }
#   PROTECTED_SETTINGS
# }


resource "azurerm_virtual_machine_extension" "install-sql" {
  count                = var.install_extensions ? 1 : 0
  name                 = "install-ssms"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"


  #protected_settings = <<PROTECTED_SETTINGS
  #  {
  #    "commandToExecute": "powershell.exe -Command \"./agentsetup.ps1; exit 0;\""
  #  }
  #PROTECTED_SETTINGS

  # https://raw.githubusercontent.com/Azure/ARO-Landing-Zone-Accelerator/main/deployment/CLI/03%20vm/start_script.ps1
  # https://raw.githubusercontent.com/Azure/appservice-landing-zone-accelerator/feature/secure-baseline-scenario/scenarios/secure-baseline-multitenant/Terraform/modules/spoke/devops-vm/ssms-setup.ps1
  # https://raw.githubusercontent.com/cykreng/Enterprise-Scale-AppService/main/reference-implementations/LOB-ILB-ASEv3/bicep/shared/agentsetup.ps1

  #"commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File agentsetup.ps1 -Command \"./agentsetup.ps1; exit 0;\"",
  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ssms-setup.ps1 ",
        "fileUris": ["https://raw.githubusercontent.com/Azure/appservice-landing-zone-accelerator/feature/secure-baseline-scenario/scenarios/secure-baseline-multitenant/Terraform/modules/spoke/devops-vm/ssms-setup.ps1"]
    }
  PROTECTED_SETTINGS
}
