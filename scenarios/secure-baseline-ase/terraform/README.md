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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_shared-vms"></a> [shared-vms](#module\_shared-vms) | ./modules/shared | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service_environment_v3.ase](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_environment_v3) | resource |
| [azurerm_bastion_host.bastionHost](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) | resource |
| [azurerm_private_dns_a_record.privateDnsZoneName_Amp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_a_record.privateDnsZoneName_all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_a_record.privateDnsZoneName_scm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.privateDnsZone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.privateDnsZoneName_vnetLink](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_public_ip.bastionHostPippublicIp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.aserg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.networkrg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.sharedrg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_service_plan.appServicePlan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_subnet.vnetSpokeSubnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.vnetHub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network.vnetSpoke](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.peerhubtospoke](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.peerspoketohub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_CICDAgentNameAddressPrefix"></a> [CICDAgentNameAddressPrefix](#input\_CICDAgentNameAddressPrefix) | CIDR prefix to use for Spoke VNet | `string` | `"10.0.2.0/24"` | no |
| <a name="input_aseAddressPrefix"></a> [aseAddressPrefix](#input\_aseAddressPrefix) | CIDR prefix to use for ASE | `string` | `"10.1.1.0/24"` | no |
| <a name="input_bastionAddressPrefix"></a> [bastionAddressPrefix](#input\_bastionAddressPrefix) | CIDR prefix to use for Hub VNet | `string` | `"10.0.1.0/24"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment for which the deployment is being executed | `string` | `"dev"` | no |
| <a name="input_hubVNetNameAddressPrefix"></a> [hubVNetNameAddressPrefix](#input\_hubVNetNameAddressPrefix) | CIDR prefix to use for Hub VNet | `string` | `"10.0.0.0/16"` | no |
| <a name="input_jumpBoxAddressPrefix"></a> [jumpBoxAddressPrefix](#input\_jumpBoxAddressPrefix) | CIDR prefix to use for Jumpbox VNet | `string` | `"10.0.3.0/24"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure location where all resources should be created | `string` | `"westus2"` | no |
| <a name="input_numberOfWorkers"></a> [numberOfWorkers](#input\_numberOfWorkers) | numberOfWorkers for ASE | `number` | `3` | no |
| <a name="input_spokeVNetNameAddressPrefix"></a> [spokeVNetNameAddressPrefix](#input\_spokeVNetNameAddressPrefix) | CIDR prefix to use for Spoke VNet | `string` | `"10.1.0.0/16"` | no |
| <a name="input_vmadminPassword"></a> [vmadminPassword](#input\_vmadminPassword) | admin password for the virtual machine (devops agent, jumpbox). If none is provided, will be randomly generated and stored in the Key Vault | `string` | `null` | no |
| <a name="input_vmadminUserName"></a> [vmadminUserName](#input\_vmadminUserName) | admin username for the virtual machine (devops agent, jumpbox) | `string` | `"vmadmin"` | no |
| <a name="input_workerPool"></a> [workerPool](#input\_workerPool) | workerPool for ASE | `number` | `1` | no |
| <a name="input_workloadName"></a> [workloadName](#input\_workloadName) | A short name for the workload being deployed | `string` | `"sec-baseline-sgl"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appServicePlanId"></a> [appServicePlanId](#output\_appServicePlanId) | ID of the App Service Plan. |
| <a name="output_appServicePlanName"></a> [appServicePlanName](#output\_appServicePlanName) | Name of the App Service Plan. |
| <a name="output_aseId"></a> [aseId](#output\_aseId) | ID of the App Service Environment. |
| <a name="output_aseName"></a> [aseName](#output\_aseName) | Name of the App Service Environment. |
| <a name="output_hubSubnets"></a> [hubSubnets](#output\_hubSubnets) | Hub virtual network subnet name-to-id mapping. |
| <a name="output_hubVNetId"></a> [hubVNetId](#output\_hubVNetId) | ID of the provisioned Hub virtual network. |
| <a name="output_hubVNetName"></a> [hubVNetName](#output\_hubVNetName) | Name of the provisioned Hub virtual network. |
| <a name="output_shared-vms"></a> [shared-vms](#output\_shared-vms) | Private IP Addresses and IDs of the provisioned shared virtual machines (DevOps and Jumpbox VMs). |
| <a name="output_spokeVNetId"></a> [spokeVNetId](#output\_spokeVNetId) | ID of the provisioned Spoke virtual network. |
| <a name="output_spokeVNetName"></a> [spokeVNetName](#output\_spokeVNetName) | Name of the provisioned Spoke virtual network. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->