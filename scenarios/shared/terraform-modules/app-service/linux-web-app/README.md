# linux-web-app

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurecaf"></a> [azurecaf](#provider\_azurecaf) | 1.2.24 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.52.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_private_endpoint"></a> [private\_endpoint](#module\_private\_endpoint) | ../../private-endpoint | n/a |
| <a name="module_private_endpoint_slot"></a> [private\_endpoint\_slot](#module\_private\_endpoint\_slot) | ../../private-endpoint | n/a |

## Resources

| Name | Type |
|------|------|
| [azurecaf_name.caf_name_linwebapp](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.slot](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.webapp](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurerm_linux_web_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) | resource |
| [azurerm_linux_web_app_slot.slot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app_slot) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_appsvc_subnet_id"></a> [appsvc\_subnet\_id](#input\_appsvc\_subnet\_id) | The subnet id where the app service will be integrated | `string` | n/a | yes |
| <a name="input_enable_diagnostic_settings"></a> [enable\_diagnostic\_settings](#input\_enable\_diagnostic\_settings) | Enable diagnostic settings | `bool` | `false` | no |
| <a name="input_frontend_subnet_id"></a> [frontend\_subnet\_id](#input\_frontend\_subnet\_id) | The subnet id where the front door will be integrated | `string` | n/a | yes |
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings for the naming convention module. | `any` | n/a | yes |
| <a name="input_identity"></a> [identity](#input\_identity) | The identity type and the list of identities ids | <pre>object({<br>    type         = string<br>    identity_ids = optional(list(string))<br>  })</pre> | <pre>{<br>  "identity_ids": [],<br>  "type": "SystemAssigned"<br>}</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where all resources in this example should be created | `string` | `"westus2"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The log analytics workspace id | `string` | n/a | yes |
| <a name="input_private_dns_zone"></a> [private\_dns\_zone](#input\_private\_dns\_zone) | The private dns zone id where the app service will be integrated | <pre>object({<br>    id                  = string<br>    name                = string<br>    resource_group_name = string<br>  })</pre> | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The name of the resource group where all resources in this example should be created. | `string` | n/a | yes |
| <a name="input_service_plan_id"></a> [service\_plan\_id](#input\_service\_plan\_id) | The id of the service plan where the web application will be created | `string` | n/a | yes |
| <a name="input_service_plan_options"></a> [service\_plan\_options](#input\_service\_plan\_options) | The options for the app service | <pre>object({<br>    os_type  = string<br>    sku_name = string<br>  })</pre> | <pre>{<br>  "os_type": "Windows",<br>  "sku_name": "S1"<br>}</pre> | no |
| <a name="input_service_plan_resource"></a> [service\_plan\_resource](#input\_service\_plan\_resource) | The service plan resource where the web application will be created | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_web_app_name"></a> [web\_app\_name](#input\_web\_app\_name) | The name of the web application | `string` | n/a | yes |
| <a name="input_webapp_options"></a> [webapp\_options](#input\_webapp\_options) | The options for the app service | <pre>object({<br>    instrumentation_key  = string<br>    ai_connection_string = string<br>    slots                = list(string)<br><br>    application_stack = object({<br>      current_stack       = string # required for windows<br>      dotnet_version      = optional(string)<br>      php_version         = optional(string)<br>      node_version        = optional(string)<br>      java_version        = optional(string)<br>      python              = optional(bool)   # windows only<br>      python_version      = optional(string) # linux only<br>      java_server         = optional(string) # linux only<br>      java_server_version = optional(string) # linux only<br>      go_version          = optional(string) # linux only<br>      docker_image        = optional(string) # linux only<br>      docker_image_tag    = optional(string) # linux only<br>      go_version          = optional(string) # linux only<br>      ruby_version        = optional(string) # linux only<br>    })<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_web_app_hostname"></a> [web\_app\_hostname](#output\_web\_app\_hostname) | n/a |
| <a name="output_web_app_id"></a> [web\_app\_id](#output\_web\_app\_id) | n/a |
| <a name="output_web_app_name"></a> [web\_app\_name](#output\_web\_app\_name) | n/a |
| <a name="output_web_app_principal_id"></a> [web\_app\_principal\_id](#output\_web\_app\_principal\_id) | n/a |
| <a name="output_web_app_slot_hostname"></a> [web\_app\_slot\_hostname](#output\_web\_app\_slot\_hostname) | n/a |
| <a name="output_web_app_slot_id"></a> [web\_app\_slot\_id](#output\_web\_app\_slot\_id) | n/a |
| <a name="output_web_app_slot_name"></a> [web\_app\_slot\_name](#output\_web\_app\_slot\_name) | n/a |
| <a name="output_web_app_slot_principal_id"></a> [web\_app\_slot\_principal\_id](#output\_web\_app\_slot\_principal\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
