# spoke

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
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_configuration"></a> [app\_configuration](#module\_app\_configuration) | ../../../shared/terraform-modules/app-configuration | n/a |
| <a name="module_app_service"></a> [app\_service](#module\_app\_service) | ../../../shared/terraform-modules/app-service | n/a |
| <a name="module_devops_vm"></a> [devops\_vm](#module\_devops\_vm) | ../../../shared/terraform-modules/windows-vm | n/a |
| <a name="module_frontdoor"></a> [frontdoor](#module\_frontdoor) | ../../../shared/terraform-modules/frontdoor | n/a |
| <a name="module_key_vault"></a> [key\_vault](#module\_key\_vault) | ../../../shared/terraform-modules/key-vault | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../../shared/terraform-modules/network | n/a |
| <a name="module_private_dns_zones"></a> [private\_dns\_zones](#module\_private\_dns\_zones) | ../../../shared/terraform-modules/private-dns-zone | n/a |
| <a name="module_redis_cache"></a> [redis\_cache](#module\_redis\_cache) | ../../../shared/terraform-modules/redis | n/a |
| <a name="module_sql_database"></a> [sql\_database](#module\_sql\_database) | ../../../shared/terraform-modules/sql-database | n/a |
| <a name="module_user_defined_routes"></a> [user\_defined\_routes](#module\_user\_defined\_routes) | ../../../shared/terraform-modules/user-defined-routes | n/a |

## Resources

| Name | Type |
|------|------|
| [azurecaf_name.appsvc_subnet](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.caf_name_id_contributor](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.caf_name_id_reader](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.caf_name_law](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.caf_name_spoke_rg](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.law](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurerm_log_analytics_workspace.law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.spoke](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_user_assigned_identity.contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_integer.unique_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [azurerm_virtual_network.hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |
| [terraform_remote_state.hub](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aad_admin_group_name"></a> [aad\_admin\_group\_name](#input\_aad\_admin\_group\_name) | The name of the Azure AD group that should be granted SQL Admin permissions to the SQL Server | `string` | n/a | yes |
| <a name="input_aad_admin_group_object_id"></a> [aad\_admin\_group\_object\_id](#input\_aad\_admin\_group\_object\_id) | The object ID of the Azure AD group that should be granted SQL Admin permissions to the SQL Server | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name of your application | `string` | `"sec-baseline-1-spoke"` | no |
| <a name="input_appsvc_options"></a> [appsvc\_options](#input\_appsvc\_options) | The options for the app service | <pre>object({<br>    service_plan = object({<br>      os_type        = string<br>      sku_name       = string<br>      worker_count   = optional(number)<br>      zone_redundant = optional(bool)<br>    })<br>    web_app = object({<br>      slots = list(string)<br><br>      application_stack = object({<br>        current_stack       = string # required for windows<br>        dotnet_version      = optional(string)<br>        php_version         = optional(string)<br>        node_version        = optional(string)<br>        java_version        = optional(string)<br>        python              = optional(bool)   # windows only<br>        python_version      = optional(string) # linux only<br>        java_server         = optional(string) # linux only<br>        java_server_version = optional(string) # linux only<br>        go_version          = optional(string) # linux only<br>        docker_image        = optional(string) # linux only<br>        docker_image_tag    = optional(string) # linux only<br>        go_version          = optional(string) # linux only<br>        ruby_version        = optional(string) # linux only<br>      })<br>    })<br>  })</pre> | <pre>{<br>  "service_plan": {<br>    "os_type": "Windows",<br>    "sku_name": "S1"<br>  },<br>  "web_app": {<br>    "application_stack": {<br>      "current_stack": "dotnet",<br>      "dotnet_version": "6.0"<br>    },<br>    "slots": []<br>  }<br>}</pre> | no |
| <a name="input_appsvc_subnet_cidr"></a> [appsvc\_subnet\_cidr](#input\_appsvc\_subnet\_cidr) | The CIDR block for the subnet. | `list(string)` | <pre>[<br>  "10.240.0.0/26"<br>]</pre> | no |
| <a name="input_bastion_subnet_cidr"></a> [bastion\_subnet\_cidr](#input\_bastion\_subnet\_cidr) | [Optional] The CIDR block(s) for the bastion subnet. Defaults to 10.242.0.64/26 | `list(string)` | <pre>[<br>  "10.242.0.64/26"<br>]</pre> | no |
| <a name="input_bastion_subnet_name"></a> [bastion\_subnet\_name](#input\_bastion\_subnet\_name) | [Optional] Name of the subnet to deploy bastion resource to. Defaults to 'AzureBastionSubnet' | `string` | `"AzureBastionSubnet"` | no |
| <a name="input_deployment_options"></a> [deployment\_options](#input\_deployment\_options) | Opt-in settings for the deployment: enable WAF in Front Door, deploy Azure Firewall and UDRs in the spoke network to force outbound traffic to the Azure Firewall, deploy Redis Cache. | <pre>object({<br>    enable_waf                 = bool<br>    enable_egress_lockdown     = bool<br>    enable_diagnostic_settings = bool<br>    deploy_bastion             = bool<br>    deploy_redis               = bool<br>    deploy_sql_database        = bool<br>    deploy_app_config          = bool<br>    deploy_vm                  = bool<br>  })</pre> | <pre>{<br>  "deploy_app_config": true,<br>  "deploy_bastion": true,<br>  "deploy_redis": true,<br>  "deploy_sql_database": true,<br>  "deploy_vm": true,<br>  "enable_diagnostic_settings": true,<br>  "enable_egress_lockdown": true,<br>  "enable_waf": true<br>}</pre> | no |
| <a name="input_devops_settings"></a> [devops\_settings](#input\_devops\_settings) | The settings for the Azure DevOps agent or GitHub runner | <pre>object({<br>    github_runner = optional(object({<br>      repository_url = string<br>      token          = string<br>    }))<br><br>    devops_agent = optional(object({<br>      organization_url = string<br>      token            = string<br>    }))<br>  })</pre> | <pre>{<br>  "devops_agent": null,<br>  "github_runner": null<br>}</pre> | no |
| <a name="input_devops_subnet_cidr"></a> [devops\_subnet\_cidr](#input\_devops\_subnet\_cidr) | [Optional] The CIDR block for the subnet. Defaults to 10.240.10.128/16 | `list(string)` | <pre>[<br>  "10.240.10.128/26"<br>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment (dev, qa, staging, prod) | `string` | `"dev"` | no |
| <a name="input_firewall_subnet_cidr"></a> [firewall\_subnet\_cidr](#input\_firewall\_subnet\_cidr) | [Optional] The CIDR block(s) for the firewall subnet. Defaults to 10.242.0.0/26 | `list(string)` | <pre>[<br>  "10.242.0.0/26"<br>]</pre> | no |
| <a name="input_firewall_subnet_name"></a> [firewall\_subnet\_name](#input\_firewall\_subnet\_name) | [Optional] Name of the subnet for firewall resources. Defaults to 'AzureFirewallSubnet' | `string` | `"AzureFirewallSubnet"` | no |
| <a name="input_front_door_subnet_cidr"></a> [front\_door\_subnet\_cidr](#input\_front\_door\_subnet\_cidr) | The CIDR block for the subnet. | `list(string)` | <pre>[<br>  "10.240.0.64/26"<br>]</pre> | no |
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | [Optional] Global settings to configure each module with the appropriate naming standards. | `map(any)` | `{}` | no |
| <a name="input_hub_state_container_name"></a> [hub\_state\_container\_name](#input\_hub\_state\_container\_name) | The name of the container that holds the Terraform state for the hub | `string` | n/a | yes |
| <a name="input_hub_state_key"></a> [hub\_state\_key](#input\_hub\_state\_key) | The key of the Terraform state for the hub | `string` | n/a | yes |
| <a name="input_hub_state_resource_group_name"></a> [hub\_state\_resource\_group\_name](#input\_hub\_state\_resource\_group\_name) | The name of the resource group that holds the Terraform state for the hub | `string` | n/a | yes |
| <a name="input_hub_state_storage_account_name"></a> [hub\_state\_storage\_account\_name](#input\_hub\_state\_storage\_account\_name) | The name of the storage account that holds the Terraform state for the hub | `string` | n/a | yes |
| <a name="input_hub_vnet_cidr"></a> [hub\_vnet\_cidr](#input\_hub\_vnet\_cidr) | [Optional] The CIDR block(s) for the hub virtual network. Defaults to 10.242.0.0/20 | `list(string)` | <pre>[<br>  "10.242.0.0/20"<br>]</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where all resources in this example should be created | `string` | `"westus2"` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | [Required] Owner of the deployment. | `string` | n/a | yes |
| <a name="input_private_link_subnet_cidr"></a> [private\_link\_subnet\_cidr](#input\_private\_link\_subnet\_cidr) | The CIDR block for the subnet. | `list(string)` | <pre>[<br>  "10.240.11.0/24"<br>]</pre> | no |
| <a name="input_spoke_vnet_cidr"></a> [spoke\_vnet\_cidr](#input\_spoke\_vnet\_cidr) | [Optional] The CIDR block(s) for the virtual network for whitelisting on the firewall. Defaults to 10.240.0.0/20 | `list(string)` | <pre>[<br>  "10.240.0.0/20"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | [Optional] Additional tags to assign to your resources | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The Azure AD tenant ID for the identities. If no value provided, will use current deployment environment tenant. | `string` | `null` | no |
| <a name="input_vm_aad_admin_object_id"></a> [vm\_aad\_admin\_object\_id](#input\_vm\_aad\_admin\_object\_id) | The Azure AD object ID for the VM admin user/group. If vm\_aad\_admin\_username is not specified, this value will be used. | `string` | `null` | no |
| <a name="input_vm_aad_admin_username"></a> [vm\_aad\_admin\_username](#input\_vm\_aad\_admin\_username) | [Optional] The Azure AD username for the VM admin account. If vm\_aad\_admin\_object\_id is not specified, this value will be used. | `string` | `null` | no |
| <a name="input_vm_admin_password"></a> [vm\_admin\_password](#input\_vm\_admin\_password) | The password for the local VM admin account. Autogenerated if null. Prefer using the Azure AD admin account. | `string` | `null` | no |
| <a name="input_vm_admin_username"></a> [vm\_admin\_username](#input\_vm\_admin\_username) | The username for the local VM admin account. Autogenerated if null. Prefer using the Azure AD admin account. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_devops_vm_id"></a> [devops\_vm\_id](#output\_devops\_vm\_id) | n/a |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | n/a |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | n/a |
| <a name="output_redis_connection_string"></a> [redis\_connection\_string](#output\_redis\_connection\_string) | n/a |
| <a name="output_rg_name"></a> [rg\_name](#output\_rg\_name) | n/a |
| <a name="output_sql_db_connection_string"></a> [sql\_db\_connection\_string](#output\_sql\_db\_connection\_string) | n/a |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | n/a |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | n/a |
| <a name="output_web_app_name"></a> [web\_app\_name](#output\_web\_app\_name) | n/a |
| <a name="output_web_app_slot_name"></a> [web\_app\_slot\_name](#output\_web\_app\_slot\_name) | n/a |
| <a name="output_web_app_uri"></a> [web\_app\_uri](#output\_web\_app\_uri) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
