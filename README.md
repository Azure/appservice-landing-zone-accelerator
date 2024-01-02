# App Service Landing Zone Accelerator

This repository provides both enterprise architecture guidelines and a reference implementation for deploying Azure App Service solutions in multi-tenant and App Service Environment scenarios. It includes best practices, considerations, and deployable artifacts for implementing a common reference architecture.
45

## Table of Contents

- [App Service Landing Zone Accelerator](#app-service-landing-zone-accelerator)
  - [Table of Contents](#table-of-contents)
  - [Enterprise-Scale Architecture](#enterprise-scale-architecture)
  - [Prerequisites](#prerequisites)
  - [Getting Started](#getting-started)
    - [Step 1. Reference implementations](#step-1-reference-implementations)
    - [Step 2. Configure and test the deployment in your own environment](#step-2-configure-and-test-the-deployment-in-your-own-environment)
      - [Deploy with Azure Portal (Bicep/ARM)](#deploy-with-azure-portal-biceparm)
      - [Locally deploy with Bicep](#locally-deploy-with-bicep)
      - [Locally deploy with Terraform](#locally-deploy-with-terraform)
    - [Step 3. Configure GitHub Actions](#step-3-configure-github-actions)
    - [App Patterns](#app-patterns)
  - [Got a feedback](#got-a-feedback)
  - [Data Collection](#data-collection)
    - [Telemetry Configuration](#telemetry-configuration)
  - [Contributing](#contributing)
  - [Trademarks](#trademarks)

Visit [EnterpriseScale-AppService](https://aka.ms/EnterpriseScale-AppService) for more information.

![image](/docs/Images/home-page.gif)

## Enterprise-Scale Architecture

The enterprise architecture is broken down into six different design areas, where you can find the links to each at:
| Design Area|Considerations|Recommendations|
|--------------|--------------|--------------|
| Identity and Access Management|[Design Considerations](/docs/Design-Areas/identity-access-mgmt.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/identity-access-mgmt.md#design-recommendations)|
| Network Topology and Connectivity|[Design Considerations](/docs/Design-Areas/networking.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/networking.md#design-recommendations)|
| Management and Monitoring|[Design Considerations](/docs/Design-Areas/mgmt-monitoring.md#design-consideration)|[Design Recommendations](/docs/Design-Areas/mgmt-monitoring.md#design-recommendation)|
| Business Continuity and Disaster Recovery|[Design Considerations](/docs/Design-Areas/BCDR.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/BCDR.md#design-recommendations)|
| Security, Governance, and Compliance|[Design Considerations](/docs/Design-Areas/security-governance-compliance.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/security-governance-compliance.md#design-recommendations)|
| Application Automation and DevOps|[Design Considerations](/docs/Design-Areas/automation-devops.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/automation-devops.md#design-recommendations)|

## Prerequisites

Before you begin, ensure you have met the following requirements:

- **Azure Subscription**: You need an Azure subscription to create resources in Azure. If you don't have one, you can create a [free account](https://azure.microsoft.com/free/).

- **Azure CLI or Azure PowerShell**: You need either Azure CLI or Azure PowerShell installed and configured to interact with your Azure account. You can download them from [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and [here](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps) respectively.

- **Terraform or Bicep**: Depending on your preference, you need either Terraform or Bicep installed to deploy the infrastructure. You can download Terraform from [here](https://www.terraform.io/downloads.html) and Bicep from [here](https://github.com/Azure/bicep#installing-bicep-cli).

- **Knowledge of Azure App Service**: This project involves deploying and managing Azure App Service resources. Familiarity with Azure App Service and its concepts is recommended.

Please replace the links and the software versions with the ones that are relevant to your project.

## Getting Started

Follow the steps below to get started with the App Service Landing Zone Accelerator.

### Step 1. Reference implementations

In this project, we currently have the following reference implementations:

| Scenario | Description | Documentation | Pipeline Status |
| -------- | ----------- | ------------- | --------------- |
| :arrow_forward: [Scenario 1: App Service Secure Baseline Multi-Tenant](scenarios/secure-baseline-multitenant/README.md) | This scenario deploys a multi-tenant App Service environment with a Hub and Spoke network topology. | [README](scenarios/secure-baseline-multitenant/README.md) | [![Scenario 1: Terraform HUB Multi-tenant Secure Baseline](https://github.com/Azure/appservice-landing-zone-accelerator/actions/workflows/scenario1.terraform.hub.yml/badge.svg?branch=main)](https://github.com/Azure/appservice-landing-zone-accelerator/actions/workflows/scenario1.terraform.hub.yml) [![Scenario 1: Terraform SPOKE Multi-tenant Secure Baseline](https://github.com/Azure/appservice-landing-zone-accelerator/actions/workflows/scenario1.terraform.spoke.yml/badge.svg)](https://github.com/Azure/appservice-landing-zone-accelerator/actions/workflows/scenario1.terraform.spoke.yml) [![Scenario 1: Bicep Multi-Tenant ASEv3 Secure Baseline](https://github.com/Azure/appservice-landing-zone-accelerator/actions/workflows/ase-multitenant.bicep.yml/badge.svg?branch=main)](https://github.com/Azure/appservice-landing-zone-accelerator/actions/workflows/ase-multitenant.bicep.yml) |

> **Note**  
  Currently, the App Service Secure Baseline Multi-Tenant is the only reference implementation available. However, both the Terraform and Bicep configuration files have feature flags available to accommodate additional scenarios. More reference input files will be provided to accommodate additional reference implementations in the future.

### Step 2. Configure and test the deployment in your own environment

With the selected reference implementation, you can now choose between `Bicep` or `Terraform` to deploy the scenario's infrastructure.

#### Deploy with Azure Portal (Bicep/ARM)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fappservice-landing-zone-accelerator%2Fmain%2Fscenarios%2Fsecure-baseline-multitenant%2Fazure-resource-manager%2Fmain.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fappservice-landing-zone-accelerator%2Fmain%2Fscenarios%2Fsecure-baseline-multitenant%2Fazure-resource-manager%2Fmain-portal-ux.json)

#### Locally deploy with Bicep

For additional information, view the Bicep README [here](scenarios/secure-baseline-multitenant/bicep/README.md).

The Bicep configuration files are located in the [scenarios/secure-baseline-multitenant/bicep](scenarios/secure-baseline-multitenant/bicep/) directory.

Before deploying the Bicep IaC artifacts, you need to review and customize the values of the parameters in the [main.parameters.jsonc](scenarios/secure-baseline-multitenant/bicep/main.parameters.jsonc) file.

> **Note**  
  Azure Developer CLI (azd) is also supported as a deployment method. Since azd CLI does not support parameter files with *jsonc* extension, we provide a simple json parameter file (which does not contain inline comments)

The expandable table below summarizes the available parameters and the possible values that can be set.

<details>
<summary><h4>Bicep Configuration Parameters Table</h4></summary>

| Name | Description | Example | 
|------|-------------|---------|
|workloadName|A suffix that will be used to name the resources in a pattern similar to ` <resourceAbbreviation>-<workloadName> ` . Must be up to 10 characters long, alphanumeric with dashes|app-svc-01|
|location|Azure region where the resources will be deployed in|northeurope|
|environment|Required. The name of the environment (e.g. "dev", "test", "prod", "preprod", "staging", "uat", "dr", "qa"). Up to 8 characters long.|dev|
|deployAseV3|Optional, default is false. Set to true if you want to deploy ASE v3 instead of Multitenant App Service Plan.|false|
|vnetHubResourceId|If empty, then a new hub will be created. If you select not to deploy a new Hub resource group, set the resource id of the Hub Virtual Network that you want to peer to. In that case, no new hub will be created and a peering will be created between the new spoke and and existing hub vnet|/subscriptions/<subscription_id>/ resourceGroups/<rg_name>/providers/ Microsoft.Network/virtualNetworks/<vnet_name>|
|firewallInternalIp|If you select to create a new Hub, the UDR for locking the egress traffic will be created as well, no matter what value you set to that variable. However, if you select to connect to an existing hub, then you need to provide the internal IP of the azure firewal so that the deployment can create the UDR for locking down egress traffic. If not given, no UDR will be created||
|vnetHubAddressSpace|If you deploy a new hub, you need to set the appropriate CIDR of the newly created Hub virtual network|10.242.0.0/20|
|subnetHubFirewallAddressSpace|CIDR of the subnet that will host the azure Firewall|10.242.0.0/26|
|subnetHubBastionAddressSpace|CIDR of the subnet that will host the Bastion Service|10.242.0.64/26|
|vnetSpokeAddressSpace|CIDR of the spoke vnet that will hold the app services plan and the rest supporting services (and their private endpoints)|10.240.0.0/20|
|subnetSpokeAppSvcAddressSpace|CIDR of the subnet that will hold the app services plan. ATTENTION: If you deploy ASEv3 this CIDR should be x.x.x.x/24 |10.240.0.0/26 (*USE 10.240.0.0/24 if deployAseV3=true*)|
|subnetSpokeDevOpsAddressSpace|CIDR of the subnet that will hold devOps agents etc|10.240.10.128/26|
|subnetSpokePrivateEndpointAddressSpace|CIDR of the subnet that will hold the private endpoints of the supporting services|10.240.11.0/24|
|webAppPlanSku|Defines the name, tier, size, family and capacity of the App Service Plan. Plans ending to _AZ, are deplying at least three instances in three Availability Zones. select one from: 'S1', 'S2', 'S3', 'P1V3', 'P2V3', 'P3V3', 'P1V3_AZ', 'P2V3_AZ', 'EP1', 'EP2', 'EP3', 'ASE_I1V2_AZ', 'ASE_I2V2_AZ', 'ASE_I3V2_AZ' ||
|webAppBaseOs|The OS for the App service plan. Two options available: Windows or Linux||
|resourceTags|Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)|"resourceTags": {<br>         "value": { <br>               "deployment": "bicep", <br>  "key1": "value1" <br>           } <br>         } |
|enableEgressLockdown|Feature Flag: te (or not) a UDR for the App Service Subnet, to route all egress traffic through Hub Azure Firewall|
|deployRedis|Feature Flag: Deploy (or not) a redis cache |
|deployAzureSql|Feature Flag: Deploy (or not) an Azure SQL with default database|
|deployAppConfig|Feature Flag: Deploy (or not) an Azure app configuration|
|deployJumpHost|Feature Flag: Deploy (or not) an Azure virtual machine (to be used as jumphost)|
|autoApproveAfdPrivateEndpoint|Default value: true. Set to true if you want to auto approve the Private Endpoint of the AFD Premium. See details [regarding approving the App Service private endpoint connection from Front Door](#approve-the-app-service-private-endpoint-connection-from-front-door-in-the-azure-portal) | false
|sqlServerAdministrators|The Azure Active Directory (AAD) administrator group used for SQL Server authentication.  The Azure AD group must be created before running deployment. This has three values that need to be filled, as shown below <br> **login**: the name of the AAD Group <br> **sid**: the object id  of the AAD Group <br> **tenantId**: The tenantId of the AAD ||

</details>

#### Locally deploy with Terraform

1. Ensure you are logged in to Azure CLI and have selected the correct subscription.
1. Navigate to the Terraform deployment directory (same directory as the `main.tf` file).
    - [scenarios/secure-baseline-multitenant/terraform/hub](scenarios/secure-baseline-multitenant/terraform/hub/)
    - [scenarios/secure-baseline-multitenant/terraform/spoke](scenarios/secure-baseline-multitenant/terraform/spoke/)
    > **Note**  
    > The GitHub Action deployments for Terraform `hub` and `spoke` are currently separated due to the amount of time both components take to deploy. It is advised to use a self-hosted agent to ensure the deployment does not timeout.
1. Familiarize yourself with the deployment files:
    - `main.tf` - Contains the Terraform provider configurations for the selected deployment/module. Note the `backend "azurerm" {}` block as this configures your [Terraform deployment's remote state](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm).  Also contains the resource group definitions to host the deployed resources.
    - `_locals.tf` - Contains the local variable declarations as well as custom logic to support naming and tagging conventions across each module.
    - `variables.tf` - Contains the input variable declarations for the selected deployment/module.
    - `outputs.tf` - Contains the output variable declarations for the selected deployment/module.
    - other `.tf` files - Contains groupings of resources for organizational purposes.
    - `Parameters/uat.tfvars` - Reference input parameter file for the UAT environment.
1. Navigate to the Terraform deployment directory (same directory as the `main.tf` file).
1. Run `terraform init` to initialize the deployment.
1. Run `terraform plan -var-file="Parameters/uat.tfvars"` to review the deployment plan.
1. Run `terraform apply -var-file="Parameters/uat.tfvars"` to deploy the resources.

### Step 3. Configure GitHub Actions

> **Note**  
  The GitHub Actions pipelines are currently configured to deploy the Terraform `hub` and `spoke` deployments. The Bicep pipelines are currently in development.

GitHub Actions pipelines are located in the [`.github/workflows`](.github/workflows/) directory with templates stored in the [`.github/actions`](.github/actions/) directory.i

1. Create an Azure AD Service Principal for OIDC Authentication
    - Reference the following documentation to configure your Azure AD Service Principal: [OIDC authentication to Azure](https://learn.microsoft.com/en-us/azure/active-directory/saas-apps/github-enterprise-managed-user-oidc-provisioning-tutorial).
1. Configure your GitHub Actions Secrets
    - In your forked repository, navigate to `Settings > Secrets and variables > Actions`.
    - Create the following secrets:
      | Secret Name | Description | Example Value |
      |-------------|-------------|---------------|
      | `AZURE_CLIENT_ID` | GUID value for the Client ID of the service principal to authenticate with | `00000000-0000-0000-0000-000000000000` |
      | `AZURE_SUBSCRIPTION_ID` | GUID value for the Subscription ID to deploy resources to | `00000000-0000-0000-0000-000000000000` |
      | `AZURE_TENANT_ID` | GUID value for the Tenant ID of the service principal to authenticate with | `00000000-0000-0000-0000-000000000000` |
      | `AZURE_TF_STATE_RESOURCE_GROUP_NAME` | [**Optional**] For Terraform only: override value to configure the remote state resource group name | `rg-terraform-state` |
      | `AZURE_TF_STATE_STORAGE_ACCOUNT_NAME` | [**Optional**] For Terraform only: override value to configure the remote state storage account name | `tfstate` |
      | `AZURE_TF_STATE_STORAGE_CONTAINER_NAME` | [**Optional**] For Terraform only: override value to configure the remote state storage container name | `tfstate` |
      | `ACCOUNT_NAME` | [**Optional**] The Azure DevOps organization URL or GitHub Actions account name (see Example Value column) to use when provisioning the pipeline agent on the self-hosted DevOps Agent VM | `https://dev.azure.com/ORGNAME` OR `github.com/ORGUSERNAME` OR `none` |
      | `PAT` | [**Optional**] Personal Access Token for the DevOps VM to leverage on provisioning the pipeline agent on the self-hosted DevOps Agent VM | `asdf1234567` |

---

### App Patterns

Looking for developer-focused reference implementation? Check out Reliable Web Patterns for App Service.

:arrow_forward: [Reliable web app pattern for .NET](https://github.com/Azure/reliable-web-app-pattern-dotnet)

---

## Got a feedback

Please leverage [issues](https://github.com/Azure/appservice-landing-zone-accelerator/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc) if you have any feedback or request on how we can improve on this repository.

---

## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft's privacy statement. Our privacy statement is located at [https://go.microsoft.com/fwlink/?LinkId=521839](https://go.microsoft.com/fwlink/?LinkId=521839). You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.

### Telemetry Configuration

Telemetry collection is on by default.

To opt-out, set the variable enableTelemetry to `false` in Bicep/ARM file and disable_terraform_partner_id to `false` on Terraform files.

---

## Contributing

See more at [Contributing](CONTRIBUTING.md)

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.

Any use of third-party trademarks or logos are subject to those third-party's policies.
