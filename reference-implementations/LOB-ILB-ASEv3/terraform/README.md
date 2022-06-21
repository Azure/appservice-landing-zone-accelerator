# App Service Landing Zone Accelerator - Terraform Implementation Guide

## Table of Contents

## Architecture

### Overview

The Azure App Service landing zone accelerator is an open-source collection of architectural guidance and reference implementation to accelerate deployment of Azure App Service at scale. It can provide a specific architectural approach and reference implementation via infrastructure as code templates to prepare your landing zones. The landing zones adhere to the architecture and best practices of the Cloud Adoption Framework.

The architectural approach can be used as design guidance for greenfield implementation and as an assessment for brownfield customers already using App Service. The reference implementation can be adapted to produce an architecture that fits your way and puts your organization on a path to sustainable scale.

The provided infrastructure-as-code template can be modified to fit your naming conventions, use existing resources (DevOps agent, key vault, and so on), and use different modes of App Service Environment v3.

![AppServiceLandingZoneArchitecture.png](../../../docs\Images\AppServiceLandingZoneArchitecture.png)

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

### Deploy the App Service

#### Configure Terraform Remote State

To configure your Terraform deployment to use the newly provisioned storage account and container, edit the [`./backend.tf`](./backend.tf) file at lines 8-12 as below:

```hcl
  backend "azurerm" {
    resource_group_name  = "my-rg-name"
    storage_account_name = "mystorageaccountname"
    container_name       = "tfstate"
    key                  = "ShillingParts/app.tfstate"
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

## :straight_ruler: Project Structure

This repository is divided into two major components: `Modules` and `Solutions`

## Further Reading

### Design Guidelines

These articles provide guidelines for creating your landing zone:

* [Identity and access management](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/app-services/identity-and-access-management)
* [Network topology and connectivity](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/app-services/network-topology-and-connectivity)
* [Security](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/app-services/security)
* [Management](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/app-services/management)
* [Governance](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/app-services/governance)
* [Platform automation and DevOps](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/app-services/platform-automation-and-devops)

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit <https://cla.opensource.microsoft.com>.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

## Code of conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
