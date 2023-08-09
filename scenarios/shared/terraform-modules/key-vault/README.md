# key-vault

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurecaf"></a> [azurecaf](#provider\_azurecaf) | 1.2.25 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.60.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurecaf_name.caf_name_akv](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.private_endpoint](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_private_dns_a_record.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.secrets_officer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.secrets_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name of your application | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment (dev, test, prod...) | `string` | `"dev"` | no |
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings for the naming convention module. | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where all resources in this example should be created | `string` | `"westus2"` | no |
| <a name="input_private_dns_zone"></a> [private\_dns\_zone](#input\_private\_dns\_zone) | The private dns zone id where the app service will be integrated | <pre>object({<br>    id                  = string<br>    name                = string<br>    resource_group_name = string<br>  })</pre> | n/a | yes |
| <a name="input_private_link_subnet_id"></a> [private\_link\_subnet\_id](#input\_private\_link\_subnet\_id) | The subnet id | `string` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The name of the resource group where all resources in this example should be created. | `string` | n/a | yes |
| <a name="input_secret_officer_identities"></a> [secret\_officer\_identities](#input\_secret\_officer\_identities) | The list of identities that will be granted secret officer permissions | `list(string)` | `[]` | no |
| <a name="input_secret_reader_identities"></a> [secret\_reader\_identities](#input\_secret\_reader\_identities) | The list of identities that will be granted secret reader permissions | `list(string)` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The sku name for the app service plan | `string` | `"standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The Azure AD tenant ID for the identities. If no value provided, will use current deployment environment tenant. | `string` | `null` | no |
| <a name="input_unique_id"></a> [unique\_id](#input\_unique\_id) | The unique id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vault_name"></a> [vault\_name](#output\_vault\_name) | n/a |
| <a name="output_vault_uri"></a> [vault\_uri](#output\_vault\_uri) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
