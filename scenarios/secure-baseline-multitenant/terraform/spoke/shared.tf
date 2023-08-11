
locals {
  az_cli_commands = <<-EOT
    az login --identity --username ${azurerm_user_assigned_identity.contributor.principal_id} --allow-no-subscriptions
    az keyvault secret set --vault-name ${module.key_vault.vault_name} --name 'redis-connstring' --value '${local.redis_connstring}'
    az appconfig kv set --auth-mode login --endpoint ${module.app_configuration[0].endpoint} --key 'sql-connstring' --value '${local.sql_connstring}' --label '${var.environment}' -y
  EOT
}


module "devops_vm" {
  count = var.deployment_options.deploy_vm ? 1 : 0

  source = "../../../shared/terraform-modules/windows-vm"

  resource_group      = azurerm_resource_group.spoke.name
  vm_name             = "devops"
  location            = var.location
  vm_subnet_id        = module.network.subnets[index(module.network.subnets.*.name, "devops")].id
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  aad_admin_username  = var.vm_aad_admin_username
  aad_admin_object_id = var.vm_aad_admin_object_id
  global_settings     = local.global_settings

  tags = local.base_tags

  identity = {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.contributor.id
    ]
  }
}
