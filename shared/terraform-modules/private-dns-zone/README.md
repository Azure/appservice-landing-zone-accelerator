# private-dns-zone

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_private_dns_zone_vnet_link"></a> [private\_dns\_zone\_vnet\_link](#module\_private\_dns\_zone\_vnet\_link) | ./dns-zone-vnet-link | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns_zones"></a> [dns\_zones](#input\_dns\_zones) | A list of DNS zones to create. | `list(string)` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The name of the resource group where the private DNS zones will be created. | `string` | n/a | yes |
| <a name="input_vnet_links"></a> [vnet\_links](#input\_vnet\_links) | A list of virtual networks to link to the DNS zone. | <pre>list(object({<br>    vnet_id             = string<br>    vnet_resource_group = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_zones"></a> [dns\_zones](#output\_dns\_zones) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
