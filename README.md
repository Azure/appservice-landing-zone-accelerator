# App Service Landing Zone Accelerator

This repository encompasses both enterprise architecture guidelines and a reference implementation for deploying Azure App Service solutions in multi-tenant and App Service Environment scenarios. It includes best practices, considerations and deployable artifacts for implementing a common reference architecture.

[aka.ms/EnterpriseScale-AppService](https://aka.ms/EnterpriseScale-AppService)

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

## Enterprise-Scale Reference Implementation

In this repo you will find reference implementations with supporting Infrastructure as Code templates. More reference implementations will be added as they become available. 

## Next Steps to implement the Azure App Service Landing Zone Accelerator

### Step 1. Reference implementations

Pick one of the scenarios below to get started on a reference implementation.

:arrow_forward: [Scenario 1: Multitenant App Service Secure Baseline](scenarios/secure-baseline-multitenant/README.md)

:arrow_forward: [Scenario 2: Line of Business application using internal App Service Environment v3](scenarios/secure-baseline-ase//README.md)

For configuring the GitHub Actions pipelines, please refer to the [GitHub Actions](docs/github-actions.md) documentation.

### Step 2. Configure and test the deployment on your own environment

With the selected reference implementation, you can now choose between `Bicep` or `Terraform` to deploy the scenario's infrastructure.

#### Deploying Bicep

#### Deploying Terraform

1. Ensure you are logged in to Azure CLI and have selected the correct subscription.
1. Navigate to the Terraform deployment directory (same directory as the `main.tf` file).
    - [scenarios/secure-baseline-multitenant/terraform/hub](scenarios/secure-baseline-multitenant/terraform/hub/)
    - [scenarios/secure-baseline-multitenant/terraform/spoke](scenarios/secure-baseline-multitenant/terraform/spoke/)
    - [scenarios/secure-baseline-ase/terraform](scenarios/secure-baseline-ase/terraform)
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
      | `AZURE_TF_STATE_RESOURCE_GROUP_NAME` | Optional override value to configure the remote state resource group name | `rg-terraform-state` |
      | `AZURE_TF_STATE_STORAGE_ACCOUNT_NAME` | Optional override value to configure the remote state storage account name | `tfstate` |
      | `AZURE_TF_STATE_STORAGE_CONTAINER_NAME` | Optional override value to configure the remote state storage container name | `tfstate` |
      | `ACCOUNT_NAME` | | `https://dev.azure.com/ORGNAME` OR `github.com/ORGUSERNAME` OR `none` |
      | `PAT` | Personal Access Token for the DevOps VM to leverage on provisioning the pipeline agent | `asdf1234567` |

---
### App Patterns
Looking for developer-focused reference implementation? Check out Reliable Web Patterns for App Service. 

:arrow_forward: [Reliable web app pattern for .NET](https://github.com/Azure/reliable-web-app-pattern-dotnet)

---

## Got a feedback

Please leverage issues if you have any feedback or request on how we can improve on this repository.

---
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft's privacy statement. Our privacy statement is located at https://go.microsoft.com/fwlink/?LinkId=521839. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.

### Telemetry Configuration

Telemetry collection is on by default.

To opt-out, set the variable enableTelemetry to `false` in Bicep/ARM file and disable_terraform_partner_id to `false` on Terraform files.

---
## Contributing

See more at [Contributing](CONTRIBUTING.md)

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
