# windows-vm-ext

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.59.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_machine_extension.aad](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.install_ssms](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_azure_ad_join"></a> [enable\_azure\_ad\_join](#input\_enable\_azure\_ad\_join) | True to enable Azure AD join of the VM. | `bool` | `true` | no |
| <a name="input_enroll_with_mdm"></a> [enroll\_with\_mdm](#input\_enroll\_with\_mdm) | True to enroll the device with an approved MDM provider like Intune. | `bool` | `true` | no |
| <a name="input_install_extensions"></a> [install\_extensions](#input\_install\_extensions) | n/a | `bool` | `false` | no |
| <a name="input_mdm_id"></a> [mdm\_id](#input\_mdm\_id) | The default value is the MDM Id for Intune, but you can use your own MDM id if you want to use a different MDM service. | `string` | `"0000000a-0000-0000-c000-000000000000"` | no |
| <a name="input_remote_exec_commands"></a> [remote\_exec\_commands](#input\_remote\_exec\_commands) | values to pass to the remote-exec provisioner | `list(string)` | `[]` | no |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | value of the vm id | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
