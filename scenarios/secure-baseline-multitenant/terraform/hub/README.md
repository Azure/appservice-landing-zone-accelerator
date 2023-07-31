# hub

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3 |
| <a name="requirement_azurecaf"></a> [azurecaf](#requirement\_azurecaf) | >=1.2.23 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.66.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurecaf"></a> [azurecaf](#provider\_azurecaf) | 1.2.26 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.67.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ../../../shared/terraform-modules/bastion | n/a |
| <a name="module_firewall"></a> [firewall](#module\_firewall) | ../../../shared/terraform-modules/firewall | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../../shared/terraform-modules/network | n/a |

## Resources

| Name | Type |
|------|------|
| [azurecaf_name.caf_name_hub_rg](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurerm_resource_group.hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | [Required] The name of your application | `string` | `"sec-baseline-1-hub"` | no |
| <a name="input_bastion_subnet_cidr"></a> [bastion\_subnet\_cidr](#input\_bastion\_subnet\_cidr) | [Optional] The CIDR block(s) for the bastion subnet. Defaults to 10.242.0.64/26 | `list(string)` | <pre>[<br>  "10.242.0.64/26"<br>]</pre> | no |
| <a name="input_bastion_subnet_name"></a> [bastion\_subnet\_name](#input\_bastion\_subnet\_name) | [Optional] Name of the subnet to deploy bastion resource to. Defaults to 'AzureBastionSubnet' | `string` | `"AzureBastionSubnet"` | no |
| <a name="input_deployment_options"></a> [deployment\_options](#input\_deployment\_options) | Opt-in settings for the deployment: enable WAF in Front Door, deploy Azure Firewall and UDRs in the spoke network to force outbound traffic to the Azure Firewall, deploy Redis Cache. | <pre>object({<br>    enable_waf                 = bool<br>    enable_egress_lockdown     = bool<br>    enable_diagnostic_settings = bool<br>    deploy_bastion             = bool<br>    deploy_redis               = bool<br>    deploy_sql_database        = bool<br>    deploy_app_config          = bool<br>    deploy_vm                  = bool<br>  })</pre> | <pre>{<br>  "deploy_app_config": true,<br>  "deploy_bastion": true,<br>  "deploy_redis": true,<br>  "deploy_sql_database": true,<br>  "deploy_vm": true,<br>  "enable_diagnostic_settings": true,<br>  "enable_egress_lockdown": true,<br>  "enable_waf": true<br>}</pre> | no |
| <a name="input_devops_subnet_cidr"></a> [devops\_subnet\_cidr](#input\_devops\_subnet\_cidr) | [Optional] The CIDR block for the subnet. Defaults to 10.240.10.128/16 | `list(string)` | <pre>[<br>  "10.240.10.128/26"<br>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | [Required] The environment (dev, qa, staging, prod) | `string` | n/a | yes |
| <a name="input_firewall_subnet_cidr"></a> [firewall\_subnet\_cidr](#input\_firewall\_subnet\_cidr) | [Optional] The CIDR block(s) for the firewall subnet. Defaults to 10.242.0.0/26 | `list(string)` | <pre>[<br>  "10.242.0.0/26"<br>]</pre> | no |
| <a name="input_firewall_subnet_name"></a> [firewall\_subnet\_name](#input\_firewall\_subnet\_name) | [Optional] Name of the subnet for firewall resources. Defaults to 'AzureFirewallSubnet' | `string` | `"AzureFirewallSubnet"` | no |
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | [Optional] Global settings to configure each module with the appropriate naming standards. | `map` | `{}` | no |
| <a name="input_hub_vnet_cidr"></a> [hub\_vnet\_cidr](#input\_hub\_vnet\_cidr) | [Optional] The CIDR block(s) for the hub virtual network. Defaults to 10.242.0.0/20 | `list(string)` | <pre>[<br>  "10.242.0.0/20"<br>]</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | [Required] The Azure region where all resources in this example should be created | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | [Required] Email or unique ID of the owner(s) for this deployment | `string` | n/a | yes |
| <a name="input_spoke_vnet_cidr"></a> [spoke\_vnet\_cidr](#input\_spoke\_vnet\_cidr) | [Optional] The CIDR block(s) for the virtual network for whitelisting on the firewall. Defaults to 10.240.0.0/20 | `list(string)` | <pre>[<br>  "10.240.0.0/20"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | [Optional] Additional tags to assign to your resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_name"></a> [bastion\_name](#output\_bastion\_name) | n/a |
| <a name="output_firewall_private_ip"></a> [firewall\_private\_ip](#output\_firewall\_private\_ip) | n/a |
| <a name="output_firewall_rules"></a> [firewall\_rules](#output\_firewall\_rules) | n/a |
| <a name="output_rg_name"></a> [rg\_name](#output\_rg\_name) | n/a |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | n/a |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
