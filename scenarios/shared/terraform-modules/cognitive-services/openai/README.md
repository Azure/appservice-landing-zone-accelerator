# openai

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurecaf"></a> [azurecaf](#provider\_azurecaf) | 1.2.26 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.72.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurecaf_name.caf_name_akv](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurerm_cognitive_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) | resource |
| [azurerm_cognitive_deployment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_deployment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application. A corresponding tag would be created on the created resources if `var.default_tags_enabled` is `true`. | `string` | `""` | no |
| <a name="input_custom_subdomain_name"></a> [custom\_subdomain\_name](#input\_custom\_subdomain\_name) | The subdomain name used for token-based authentication. Changing this forces a new resource to be created. Leave this variable as default would use a default name with random suffix. | `string` | `null` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | type = object({<br>  key\_vault\_key\_id   = (Required) The ID of the Key Vault Key which should be used to Encrypt the data in this OpenAI Account.<br>  identity\_client\_id = (Optional) The Client ID of the User Assigned Identity that has access to the key. This property only needs to be specified when there're multiple identities attached to the OpenAI Account.<br>}) | <pre>object({<br>    key_vault_key_id   = string<br>    identity_client_id = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_deployment"></a> [deployment](#input\_deployment) | type = map(object({<br>  name                 = (Required) The name of the Cognitive Services Account Deployment. Changing this forces a new resource to be created.<br>  cognitive\_account\_id = (Required) The ID of the Cognitive Services Account. Changing this forces a new resource to be created.<br>  model = {<br>    model\_format  = (Required) The format of the Cognitive Services Account Deployment model. Changing this forces a new resource to be created. Possible value is OpenAI.<br>    model\_name    = (Required) The name of the Cognitive Services Account Deployment model. Changing this forces a new resource to be created.<br>    model\_version = (Required) The version of Cognitive Services Account Deployment model.<br>  }<br>  scale = {<br>    scale\_type = (Required) Deployment scale type. Possible value is Standard. Changing this forces a new resource to be created.<br>  }<br>  rai\_policy\_name = (Optional) The name of RAI policy. Changing this forces a new resource to be created.<br>})) | <pre>map(object({<br>    name            = string<br>    model_format    = string<br>    model_name      = string<br>    model_version   = string<br>    scale_type      = string<br>    rai_policy_name = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_dynamic_throttling_enabled"></a> [dynamic\_throttling\_enabled](#input\_dynamic\_throttling\_enabled) | Determines whether or not dynamic throttling is enabled. If set to `true`, dynamic throttling will be enabled. If set to `false`, dynamic throttling will not be enabled. | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment of the application. A corresponding tag would be created on the created resources if `var.default_tags_enabled` is `true`. | `string` | `""` | no |
| <a name="input_fqdns"></a> [fqdns](#input\_fqdns) | List of FQDNs allowed for the Cognitive Account. | `list(string)` | `null` | no |
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings for the naming convention module. | `any` | n/a | yes |
| <a name="input_identity"></a> [identity](#input\_identity) | type = object({<br>  type         = (Required) The type of the Identity. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned`.<br>  identity\_ids = (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this OpenAI Account.<br>}) | <pre>object({<br>    type         = string<br>    identity_ids = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_local_auth_enabled"></a> [local\_auth\_enabled](#input\_local\_auth\_enabled) | Whether local authentication methods is enabled for the Cognitive Account. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure OpenAI deployment region. Set this variable to `null` would use resource group's location. | `string` | n/a | yes |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | type = set(object({<br>  default\_action = (Required) The Default Action to use when no rules match from ip\_rules / virtual\_network\_rules. Possible values are `Allow` and `Deny`.<br>  ip\_rules                    = (Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Cognitive Account.<br>  virtual\_network\_rules = optional(set(object({<br>    subnet\_id                            = (Required) The ID of a Subnet which should be able to access the OpenAI Account.<br>    ignore\_missing\_vnet\_service\_endpoint = (Optional) Whether ignore missing vnet service endpoint or not. Default to `false`.<br>  })))<br>})) | <pre>set(object({<br>    default_action = string<br>    ip_rules       = optional(set(string))<br>    virtual_network_rules = optional(set(object({<br>      subnet_id                            = string<br>      ignore_missing_vnet_service_endpoint = optional(bool, false)<br>    })))<br>  }))</pre> | `null` | no |
| <a name="input_outbound_network_access_restricted"></a> [outbound\_network\_access\_restricted](#input\_outbound\_network\_access\_restricted) | Whether outbound network access is restricted for the Cognitive Account. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is allowed for the Cognitive Account. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the azure resource group to use. The resource group must exist. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Specifies the SKU Name for this Cognitive Service Account. Possible values are `F0`, `F1`, `S0`, `S`, `S1`, `S2`, `S3`, `S4`, `S5`, `S6`, `P0`, `P1`, `P2`, `E0` and `DC0`. Default to `S0`. | `string` | `"S0"` | no |
| <a name="input_storage"></a> [storage](#input\_storage) | type = list(object({<br>  storage\_account\_id = (Required) Full resource id of a Microsoft.Storage resource.<br>  identity\_client\_id = (Optional) The client ID of the managed identity associated with the storage resource.<br>})) | <pre>list(object({<br>    storage_account_id = string<br>    identity_client_id = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_openai_endpoint"></a> [openai\_endpoint](#output\_openai\_endpoint) | The endpoint used to connect to the Cognitive Service Account. |
| <a name="output_openai_primary_key"></a> [openai\_primary\_key](#output\_openai\_primary\_key) | The primary access key for the Cognitive Service Account. |
| <a name="output_openai_secondary_key"></a> [openai\_secondary\_key](#output\_openai\_secondary\_key) | The secondary access key for the Cognitive Service Account. |
| <a name="output_openai_subdomain"></a> [openai\_subdomain](#output\_openai\_subdomain) | The subdomain used to connect to the Cognitive Service Account. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
