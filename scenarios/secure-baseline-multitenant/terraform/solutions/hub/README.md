# hub

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3 |
| <a name="requirement_azurecaf"></a> [azurecaf](#requirement\_azurecaf) | >=1.2.23 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.49.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurecaf"></a> [azurecaf](#provider\_azurecaf) | 1.2.24 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.50.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ../../modules/bastion | n/a |
| <a name="module_firewall"></a> [firewall](#module\_firewall) | ../../modules/firewall | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../modules/network | n/a |

## Resources

| Name | Type |
|------|------|
| [azurecaf_name.bastion_host](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.firewall](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.law](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.resource_group](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.vnet](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurerm_log_analytics_workspace.law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name of your application | `string` | `"secure-baseline"` | no |
| <a name="input_appsvc_subnet_cidr"></a> [appsvc\_subnet\_cidr](#input\_appsvc\_subnet\_cidr) | The CIDR block for the subnet. | `list(string)` | `null` | no |
| <a name="input_bastion_subnet_cidr"></a> [bastion\_subnet\_cidr](#input\_bastion\_subnet\_cidr) | The CIDR block for the bastion subnet. | `list(string)` | `null` | no |
| <a name="input_deployment_options"></a> [deployment\_options](#input\_deployment\_options) | Opt-in settings for the deployment: enable WAF in Front Door, deploy Azure Firewall and UDRs in the spoke network to force outbound traffic to the Azure Firewall, deploy Redis Cache. | <pre>object({<br>    enable_waf                 = bool<br>    enable_egress_lockdown     = bool<br>    enable_diagnostic_settings = bool<br>    deploy_bastion             = bool<br>    deploy_redis               = bool<br>    deploy_sql_database        = bool<br>    deploy_app_config          = bool<br>    deploy_vm                  = bool<br>  })</pre> | <pre>{<br>  "deploy_app_config": true,<br>  "deploy_bastion": true,<br>  "deploy_redis": true,<br>  "deploy_sql_database": true,<br>  "deploy_vm": true,<br>  "enable_diagnostic_settings": true,<br>  "enable_egress_lockdown": true,<br>  "enable_waf": true<br>}</pre> | no |
| <a name="input_devops_subnet_cidr"></a> [devops\_subnet\_cidr](#input\_devops\_subnet\_cidr) | The CIDR block for the subnet. | `list(string)` | `null` | no |
| <a name="input_firewall_subnet_cidr"></a> [firewall\_subnet\_cidr](#input\_firewall\_subnet\_cidr) | The CIDR block for the firewall subnet. | `list(string)` | `null` | no |
| <a name="input_front_door_subnet_cidr"></a> [front\_door\_subnet\_cidr](#input\_front\_door\_subnet\_cidr) | The CIDR block for the subnet. | `list(string)` | `null` | no |
| <a name="input_hub_vnet_cidr"></a> [hub\_vnet\_cidr](#input\_hub\_vnet\_cidr) | The CIDR block for the hub virtual network. | `list(string)` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where all resources in this example should be created | `string` | `"westeurope"` | no |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | The short name for the Azure region where all resources in this example should be created | `string` | `"weu"` | no |
| <a name="input_spoke_vnet_cidr"></a> [spoke\_vnet\_cidr](#input\_spoke\_vnet\_cidr) | The CIDR block for the virtual network. | `list(string)` | `null` | no |

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
