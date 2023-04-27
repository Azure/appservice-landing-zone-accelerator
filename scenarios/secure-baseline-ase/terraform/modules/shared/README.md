# shared

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.50.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_devopsvm"></a> [devopsvm](#module\_devopsvm) | ../winvm | n/a |
| <a name="module_jumpboxvm"></a> [jumpboxvm](#module\_jumpboxvm) | ../winvm | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.appinsights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_key_vault.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.devopsvm_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.jumpboxvm_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_log_analytics_workspace.loganalytics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adminPassword"></a> [adminPassword](#input\_adminPassword) | n/a | `string` | `null` | no |
| <a name="input_adminUsername"></a> [adminUsername](#input\_adminUsername) | n/a | `string` | n/a | yes |
| <a name="input_bastionSubnetId"></a> [bastionSubnetId](#input\_bastionSubnetId) | n/a | `string` | n/a | yes |
| <a name="input_devOpsVMSubnetId"></a> [devOpsVMSubnetId](#input\_devOpsVMSubnetId) | n/a | `string` | n/a | yes |
| <a name="input_jumpboxVMSubnetId"></a> [jumpboxVMSubnetId](#input\_jumpboxVMSubnetId) | n/a | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_resourceGroupName"></a> [resourceGroupName](#input\_resourceGroupName) | n/a | `string` | n/a | yes |
| <a name="input_resourceSuffix"></a> [resourceSuffix](#input\_resourceSuffix) | resourceSuffix | `string` | n/a | yes |
| <a name="input_tenantId"></a> [tenantId](#input\_tenantId) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | n/a |
| <a name="output_instrumentation_key"></a> [instrumentation\_key](#output\_instrumentation\_key) | n/a |
| <a name="output_vms"></a> [vms](#output\_vms) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
