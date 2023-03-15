resource "azurerm_virtual_machine_extension" "aad" {
  count = var.enable_azure_ad_join ? 1 : 0

  name                       = "aad-login-for-windows"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  virtual_machine_id         = var.vm_id

  settings = !var.enroll_with_mdm ? null : <<SETTINGS
    {
      "mdmId": "${var.mdm_id}"
    }
  SETTINGS

  timeouts {
    create = "60m"
  }
}

resource "azurerm_virtual_machine_extension" "install_ssms" {
  count = var.install_extensions ? 1 : 0

  name                 = "install-ssms"
  virtual_machine_id   = var.vm_id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ssms-setup.ps1",
        "fileUris": ["https://raw.githubusercontent.com/Azure/appservice-landing-zone-accelerator/main/scenarios/secure-baseline-multitenant/terraform/modules/shared/windows-vm/ssms-setup.ps1"]
    }
  PROTECTED_SETTINGS

  timeouts {
    create = "60m"
  }
}

resource "azurerm_virtual_machine_extension" "az_cli_runner" {
  count = length(var.azure_cli_commands) > 0 ? 1 : 0

  name                 = "az_cli_runner"
  virtual_machine_id   = var.vm_id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File az-cli-runner.ps1 -command \"${var.azure_cli_commands}\"",
        "fileUris": ["https://raw.githubusercontent.com/Azure/appservice-landing-zone-accelerator/feature/secure-baseline-scenario-v2/scenarios/secure-baseline-multitenant/terraform/modules/shared/windows-vm-ext/az-cli-runner.ps1"]
    }
  PROTECTED_SETTINGS

  timeouts {
    create = "30m"
  }
}