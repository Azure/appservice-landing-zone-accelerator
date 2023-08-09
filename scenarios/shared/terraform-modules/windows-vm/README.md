# windows-vm

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 2.39.0 |
| <a name="provider_azurecaf"></a> [azurecaf](#provider\_azurecaf) | 1.2.25 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.60.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurecaf_name.caf_name_winvm](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurerm_key_vault_secret.admin_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.admin_username](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_network_interface.vm_nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_role_assignment.vm_admin_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_windows_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azuread_user.vm_admin](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aad_admin_object_id"></a> [aad\_admin\_object\_id](#input\_aad\_admin\_object\_id) | The Azure AD object ID for the VM admin user/group. If aad\_admin\_username is not specified, this value will be used. | `string` | `null` | no |
| <a name="input_aad_admin_username"></a> [aad\_admin\_username](#input\_aad\_admin\_username) | [Optional] The Azure AD username for the VM admin account. If aad\_admin\_object\_id is not specified, this value will be used. | `string` | `null` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | n/a | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | n/a | `string` | `null` | no |
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings for the naming convention module. | `any` | n/a | yes |
| <a name="input_identity"></a> [identity](#input\_identity) | The identity type and the list of identities ids | <pre>object({<br>    type         = string<br>    identity_ids = optional(list(string))<br>  })</pre> | <pre>{<br>  "identity_ids": [],<br>  "type": "SystemAssigned"<br>}</pre> | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | Optional ID of the key vault to store the VM password | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location (Azure region) where the resources should be created. | `string` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The name of the resource group where all resources should be created. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_vm_image_offer"></a> [vm\_image\_offer](#input\_vm\_image\_offer) | n/a | `string` | `"windows-11"` | no |
| <a name="input_vm_image_publisher"></a> [vm\_image\_publisher](#input\_vm\_image\_publisher) | n/a | `string` | `"MicrosoftWindowsDesktop"` | no |
| <a name="input_vm_image_sku"></a> [vm\_image\_sku](#input\_vm\_image\_sku) | n/a | `string` | `"win11-22h2-pro"` | no |
| <a name="input_vm_image_version"></a> [vm\_image\_version](#input\_vm\_image\_version) | n/a | `string` | `"latest"` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | name of the virtual machine | `any` | n/a | yes |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | n/a | `string` | `"Standard_B2ms"` | no |
| <a name="input_vm_subnet_id"></a> [vm\_subnet\_id](#input\_vm\_subnet\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | n/a |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | n/a |
| <a name="output_vm_key_vault_secret_ids"></a> [vm\_key\_vault\_secret\_ids](#output\_vm\_key\_vault\_secret\_ids) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
