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
    delete = "5m"
  }
}

locals {
  gh_repo   = try(var.devops_settings.github_runner.repository_url, "")
  gh_token  = try(var.devops_settings.github_runner.token, "")
  ado_org   = try(var.devops_settings.devops_agent.organization_url, "")
  ado_token = try(var.devops_settings.devops_agent.token, "")
}

resource "azurerm_virtual_machine_extension" "post_deployment" {
  name                 = "post_deployment"
  virtual_machine_id   = var.vm_id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  #   protected_settings = <<PROTECTED_SETTINGS
  # {
  #   "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File post-deployment.ps1 -az_cli_commands \\"${var.azure_cli_commands}\\" -install_ssms -github_repository \\"${local.gh_repo}\\" -github_token \\"${local.gh_token}\\" -ado_organization \\"${local.ado_org}\\" -ado_token \\"${local.ado_token}\\"",
  #   "fileUris": ["https://raw.githubusercontent.com/Azure/appservice-landing-zone-accelerator/main/scenarios/shared/scripts/win-devops-vm-extensions/post-deployment.ps1"]
  # }
  # PROTECTED_SETTINGS

  timeouts {
    create = "60m"
    delete = "5m"
  }
}