# network

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurecaf"></a> [azurecaf](#provider\_azurecaf) | 1.2.25 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.59.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurecaf_name.caf_name_vnet](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.target_to_this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.this_to_target](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings for the naming convention module. | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where all resources in this example should be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the application. | `string` | n/a | yes |
| <a name="input_peering_vnet"></a> [peering\_vnet](#input\_peering\_vnet) | The virtual network to peer with. | <pre>object({<br>    id             = string,<br>    name           = string,<br>    resource_group = string<br>  })</pre> | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The name of the resource group where all resources in this example should be created. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A list of subnets inside the virtual network. | <pre>list(object({<br>    name        = string,<br>    subnet_cidr = list(string),<br>    delegation = object({<br>      name = string,<br>      service_delegation = object({<br>        name    = string,<br>        actions = list(string)<br>      })<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_vnet_cidr"></a> [vnet\_cidr](#input\_vnet\_cidr) | The address space that is used by the virtual network. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resouce_group_name"></a> [resouce\_group\_name](#output\_resouce\_group\_name) | n/a |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |
| <a name="output_vnet"></a> [vnet](#output\_vnet) | n/a |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | n/a |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
