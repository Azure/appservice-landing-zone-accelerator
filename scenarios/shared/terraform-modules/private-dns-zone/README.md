# private-dns-zone

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
| [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns_zones"></a> [dns\_zones](#input\_dns\_zones) | A list of DNS zones to create. | `list(string)` | n/a | yes |
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings for the naming convention module. | `any` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The name of the resource group where the private DNS zones will be created. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_vnet_links"></a> [vnet\_links](#input\_vnet\_links) | A list of virtual networks to link to the DNS zone. | <pre>list(object({<br>    vnet_id             = string<br>    vnet_resource_group = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_zones"></a> [dns\_zones](#output\_dns\_zones) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
