# App Service Landing Zone Accelerator - Terraform Implementation Guide

## Table of Contents

- [App Service Landing Zone Accelerator - Terraform Implementation Guide](#app-service-landing-zone-accelerator---terraform-implementation-guide)
  - [Table of Contents](#table-of-contents)
  - [Pre-requisites](#pre-requisites)
  - [:rocket: Getting started](#rocket-getting-started)
    - [Setting up your environment](#setting-up-your-environment)
      - [Configure Terraform](#configure-terraform)
      - [Configure Remote Storage Account](#configure-remote-storage-account)
    - [Deploy the App Service Landing Zone](#deploy-the-app-service-landing-zone)
      - [Configure Terraform Remote State](#configure-terraform-remote-state)
      - [Provide Parameters Required for Deployment](#provide-parameters-required-for-deployment)
      - [Deploy](#deploy)
  - [Terraform Overview](#terraform-overview)

## Pre-requisites

1. [Terraform](#configure-terraform)
1. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
1. Azure Subscription

## :rocket: Getting started

### Setting up your environment

#### Configure Terraform

If you haven't already done so, configure Terraform using one of the following options:

* [Configure Terraform in Azure Cloud Shell with Bash](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell-bash)
* [Configure Terraform in Azure Cloud Shell with PowerShell](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell-powershell)
* [Configure Terraform in Windows with Bash](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-windows-bash)
* [Configure Terraform in Windows with PowerShell](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-windows-powershell)

#### Configure Remote Storage Account

Before you use Azure Storage as a backend, you must create a storage account.
Run the following commands or configuration to create an Azure storage account and container:

Powershell

```powershell

$RESOURCE_GROUP_NAME='tfstate'
$STORAGE_ACCOUNT_NAME="tfstate$(Get-Random)"
$CONTAINER_NAME='tfstate'

# Create resource group
New-AzResourceGroup -Name $RESOURCE_GROUP_NAME -Location eastus

# Create storage account
$storageAccount = New-AzStorageAccount -ResourceGroupName $RESOURCE_GROUP_NAME -Name $STORAGE_ACCOUNT_NAME -SkuName Standard_LRS -Location eastus -AllowBlobPublicAccess $true

# Create blob container
New-AzStorageContainer -Name $CONTAINER_NAME -Context $storageAccount.context -Permission blob

```

Alternatively, the [Terraform Dependencies](../../../.github/workflows/terraform-dependencies.yml) actions workflow can provision the Terraform remote state storage account and container. Customize the deployment by updating the `environment variables` on lines 6-11:

```yaml
env:
  location: 'westus2'
  resource_prefix: "backend-appsrvc"
  environment: "dev"
  suffix: "001"
  container_name: "tfstate"
```

For additional reading around remote state:

* [MS Doc: Store Terraform state in Azure Storage](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli)
* [TF Doc: AzureRM Provider Configuration Documentation](https://www.terraform.io/language/settings/backends/azurerm)

### Deploy the App Service Landing Zone

#### Configure Terraform Remote State

To configure your Terraform deployment to use the newly provisioned storage account and container, edit the [`./backend.tf`](./backend.tf) file at lines 8-12 as below:

```hcl
  backend "azurerm" {
    resource_group_name  = "my-rg-name"
    storage_account_name = "mystorageaccountname"
    container_name       = "tfstate"
    key                  = "myapp/terraform.tfstate"
  }
```

* `resource_group_name`: Name of the Azure Resource Group that the storage account resides in.
* `storage_account_name`: Name of the Azure Storage Account to be used to hold remote state.
* `container_name`: Name of the Azure Storage Account Blob Container to store remote state.
* `key`: Path and filename for the remote state file to be placed in the Storage Account Container. If the state file does not exist in this path, Terraform will automatically generate one for you.

#### Provide Parameters Required for Deployment

As you configured the backend remote state with your live Azure infrastructure resource values, you must also provide them for your deployment.

1. Review the available variables with their descriptions and default values in the [variables.tf](./variables.tf) file.
2. Provide any custom values to the defined variables by creating a `terraform.tfvars` file in this direcotry (`reference-implementations/LOB-ILB-ASEv3/terraform/terraform.tfvars`)
    * [TF Docs: Variable Definitions (.tfvars) Files](https://www.terraform.io/language/values/variables#variable-definitions-tfvars-files)

#### Deploy

1. Navigate to the Terraform directory `reference-implementations/LOB-ILB-ASEv3/terraform`
1. Initialize Terraform to install `required_providers` specified within the `backend.tf` and to initialize the backend remote state
    * to run locally without the remote state, comment out the `backend "azurerm"` block in `backend.tf` (lines 8-13)

    ```bash
    terraform init
    ```

1. See the planned Terraform deployment and verify resource values

    ```bash
    terraform plan
    ```

1. Deploy

    ```bash
    terraform apply
    ```

## Terraform Overview

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
| <a name="module_app_service"></a> [app\_service](#module\_app\_service) | ../../shared/terraform-modules/app-service | n/a |
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ../../shared/terraform-modules/bastion | n/a |
| <a name="module_devops_vm"></a> [devops\_vm](#module\_devops\_vm) | ../../shared/terraform-modules/windows-vm | n/a |
| <a name="module_jumpbox_vm"></a> [jumpbox\_vm](#module\_jumpbox\_vm) | ../../shared/terraform-modules/windows-vm | n/a |
| <a name="module_private_dns_zones_ase"></a> [private\_dns\_zones\_ase](#module\_private\_dns\_zones\_ase) | ../../shared/terraform-modules/private-dns-zone | n/a |
| <a name="module_vnetHub"></a> [vnetHub](#module\_vnetHub) | ../../shared/terraform-modules/network | n/a |
| <a name="module_vnetSpoke"></a> [vnetSpoke](#module\_vnetSpoke) | ../../shared/terraform-modules/network | n/a |

## Resources

| Name | Type |
|------|------|
| [azurecaf_name.caf_name_ase_rg](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.caf_name_ase_v3](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.caf_name_law](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.caf_name_network_rg](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.caf_name_shared_rg](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.law](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurerm_app_service_environment_v3.ase](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_environment_v3) | resource |
| [azurerm_log_analytics_workspace.law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.ase](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.shared](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_app_service_environment_v3.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/app_service_environment_v3) | data source |
| [azurerm_private_dns_zone.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_virtual_network.existing_spoke_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_CICDAgentNameAddressPrefix"></a> [CICDAgentNameAddressPrefix](#input\_CICDAgentNameAddressPrefix) | CIDR prefix to use for Spoke VNet | `list(string)` | <pre>[<br>  "10.0.2.0/24"<br>]</pre> | no |
| <a name="input_app_service_environment_name"></a> [app\_service\_environment\_name](#input\_app\_service\_environment\_name) | [Optional] The NAME of an already existing App Service Environment to deploy the App Service Plan to. | `string` | `null` | no |
| <a name="input_app_service_environment_resource_group_name"></a> [app\_service\_environment\_resource\_group\_name](#input\_app\_service\_environment\_resource\_group\_name) | [Optional] The Resource Group NAME of an already existing App Service Environment to deploy the App Service Plan to. Will create a new ASE v3 if not provided. | `string` | `null` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | A short name for the workload being deployed | `string` | n/a | yes |
| <a name="input_aseAddressPrefix"></a> [aseAddressPrefix](#input\_aseAddressPrefix) | CIDR prefix to use for ASE | `list(string)` | <pre>[<br>  "10.1.1.0/24"<br>]</pre> | no |
| <a name="input_bastionAddressPrefix"></a> [bastionAddressPrefix](#input\_bastionAddressPrefix) | CIDR prefix to use for Hub VNet | `list(string)` | <pre>[<br>  "10.0.1.0/24"<br>]</pre> | no |
| <a name="input_deployment_options"></a> [deployment\_options](#input\_deployment\_options) | [Optional] Deployment options to configure each module with the appropriate features. | `map` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment for which the deployment is being executed | `string` | `"dev"` | no |
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | [Optional] Global settings to configure each module with the appropriate naming standards. | `map` | `{}` | no |
| <a name="input_hubVNetNameAddressPrefix"></a> [hubVNetNameAddressPrefix](#input\_hubVNetNameAddressPrefix) | CIDR prefix to use for Hub VNet | `list(string)` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| <a name="input_jumpBoxAddressPrefix"></a> [jumpBoxAddressPrefix](#input\_jumpBoxAddressPrefix) | CIDR prefix to use for Jumpbox VNet | `list(string)` | <pre>[<br>  "10.0.3.0/24"<br>]</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure location where all resources should be created | `string` | `"westus2"` | no |
| <a name="input_numberOfWorkers"></a> [numberOfWorkers](#input\_numberOfWorkers) | numberOfWorkers for ASE | `number` | `3` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | [Required] Email or unique ID of the owner(s) for this deployment | `string` | n/a | yes |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | [Optional] The NAME of an already existing Private DNS Zone to deploy the App Service Plan to. | `string` | `null` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | [Optional] The Resource Group NAME of an already existing Private DNS Zone to deploy the App Service Plan to. Will create a new ASE v3 if not provided. | `string` | `null` | no |
| <a name="input_spokeVNetNameAddressPrefix"></a> [spokeVNetNameAddressPrefix](#input\_spokeVNetNameAddressPrefix) | CIDR prefix to use for Spoke VNet | `list(string)` | <pre>[<br>  "10.1.0.0/16"<br>]</pre> | no |
| <a name="input_spoke_vnet_name"></a> [spoke\_vnet\_name](#input\_spoke\_vnet\_name) | [Optional] The VNET NAME of an already existing spoke VNET. | `string` | `null` | no |
| <a name="input_spoke_vnet_resource_group_name"></a> [spoke\_vnet\_resource\_group\_name](#input\_spoke\_vnet\_resource\_group\_name) | [Optional] The Resource Group NAME of an already existing spoke VNET. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | [Optional] Additional tags to assign to your resources | `map(string)` | `{}` | no |
| <a name="input_vmAdminPassword"></a> [vmAdminPassword](#input\_vmAdminPassword) | admin password for the virtual machine (devops agent, jumpbox). If none is provided, will be randomly generated and stored in the Key Vault | `string` | `null` | no |
| <a name="input_vmAdminUsername"></a> [vmAdminUsername](#input\_vmAdminUsername) | admin username for the virtual machine (devops agent, jumpbox) | `string` | `"vmadmin"` | no |
| <a name="input_vm_aad_admin_object_id"></a> [vm\_aad\_admin\_object\_id](#input\_vm\_aad\_admin\_object\_id) | The Azure AD username for the VM admin account. If vm\_aad\_admin\_username is not specified, this value will be used. | `string` | `null` | no |
| <a name="input_vm_aad_admin_username"></a> [vm\_aad\_admin\_username](#input\_vm\_aad\_admin\_username) | [Optional] The Azure AD username for the VM admin account. If vm\_aad\_admin\_object\_id is not specified, this value will be used. | `string` | `null` | no |
| <a name="input_workerPool"></a> [workerPool](#input\_workerPool) | workerPool for ASE | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_default_hostname"></a> [app\_service\_default\_hostname](#output\_app\_service\_default\_hostname) | n/a |
| <a name="output_app_service_name"></a> [app\_service\_name](#output\_app\_service\_name) | n/a |
| <a name="output_aseId"></a> [aseId](#output\_aseId) | ID of the App Service Environment. |
| <a name="output_aseName"></a> [aseName](#output\_aseName) | Name of the App Service Environment. |
| <a name="output_hubVNet"></a> [hubVNet](#output\_hubVNet) | Name of the provisioned Hub virtual network. |
| <a name="output_shared-vms"></a> [shared-vms](#output\_shared-vms) | Private IP Addresses and IDs of the provisioned shared virtual machines (DevOps and Jumpbox VMs). |
| <a name="output_spokeVNet"></a> [spokeVNet](#output\_spokeVNet) | Name of the provisioned Hub virtual network. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->