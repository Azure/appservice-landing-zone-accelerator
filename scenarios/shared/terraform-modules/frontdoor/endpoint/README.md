# endpoint

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.60.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_cdn_frontdoor_endpoint.web_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_endpoint) | resource |
| [azurerm_cdn_frontdoor_origin.web_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin) | resource |
| [azurerm_cdn_frontdoor_origin_group.web_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin_group) | resource |
| [azurerm_cdn_frontdoor_route.web_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_route) | resource |
| [null_resource.web_app](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_endpoint_name"></a> [endpoint\_name](#input\_endpoint\_name) | The name of the front door endpoint. | `string` | n/a | yes |
| <a name="input_frontdoor_profile_id"></a> [frontdoor\_profile\_id](#input\_frontdoor\_profile\_id) | The front door profile id | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region of the web app | `string` | n/a | yes |
| <a name="input_private_link_target_type"></a> [private\_link\_target\_type](#input\_private\_link\_target\_type) | The private link target type | `string` | n/a | yes |
| <a name="input_web_app_hostname"></a> [web\_app\_hostname](#input\_web\_app\_hostname) | The web app hostname | `string` | n/a | yes |
| <a name="input_web_app_id"></a> [web\_app\_id](#input\_web\_app\_id) | The web app id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cdn_frontdoor_endpoint_id"></a> [cdn\_frontdoor\_endpoint\_id](#output\_cdn\_frontdoor\_endpoint\_id) | n/a |
| <a name="output_cdn_frontdoor_endpoint_uri"></a> [cdn\_frontdoor\_endpoint\_uri](#output\_cdn\_frontdoor\_endpoint\_uri) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
