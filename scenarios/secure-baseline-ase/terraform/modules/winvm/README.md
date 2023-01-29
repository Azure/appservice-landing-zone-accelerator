# winvm

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.38.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_interface.nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_virtual_machine_extension.installagent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_windows_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adminPassword"></a> [adminPassword](#input\_adminPassword) | n/a | `string` | n/a | yes |
| <a name="input_adminUserName"></a> [adminUserName](#input\_adminUserName) | n/a | `string` | n/a | yes |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | n/a | `string` | n/a | yes |
| <a name="input_installDevOpsAgent"></a> [installDevOpsAgent](#input\_installDevOpsAgent) | n/a | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_resourceGroupName"></a> [resourceGroupName](#input\_resourceGroupName) | n/a | `string` | n/a | yes |
| <a name="input_vmname"></a> [vmname](#input\_vmname) | name of the virtual machine | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
