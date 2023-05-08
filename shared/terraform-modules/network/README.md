# network

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where all resources in this example should be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the virtual network. | `string` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The name of the resource group where all resources in this example should be created. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A list of subnets inside the virtual network. | <pre>list(object({<br>    name        = string,<br>    subnet_cidr = list(string),<br>    delegation = object({<br>      name = string,<br>      service_delegation = object({<br>        name    = string,<br>        actions = list(string)<br>      })<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_vnet_cidr"></a> [vnet\_cidr](#input\_vnet\_cidr) | The address space that is used by the virtual network. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | n/a |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
