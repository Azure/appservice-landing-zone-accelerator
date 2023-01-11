# Multitenant App Service Secure Baseline Terraform Implementation

## Steps of Implementation for App Service Construction Set

A deployment of App Service-hosted workloads typically experiences a separation of duties and lifecycle management in the area of prerequisites, the host network, the App Service plan, and finally the workload itself. This reference implementation is similar. Also, be aware our primary purpose is to illustrate the topology and decisions of a baseline cluster. We feel a "step-by-step" flow will help you learn the pieces of the solution and give you insight into the relationship between them. Ultimately, lifecycle/SDLC management of your cluster and its dependencies will depend on your situation (team roles, organizational standards, tooling, etc), and must be implemented as appropriate for your needs.

## Accounting for Separation of Duties

While the code here is located in one folder in a single repo, the steps are designed to mimic how an organization may break up the deployment of various Azure components across teams, into different code repos or have them run by different pipelines with specific credentials.

## Keeping It As Simple As Possible

The code here is purposely written to avoid loops, complex variables and logic. In most cases, it is resource blocks, small modules and limited variables, with the goal of making it easier to determine what is being deployed and how they are connected. Resources are broken into separate files for future modularization or adjustments as needed by your organization.

## Terraform State Management

In this example, state is stored in an Azure Storage account that was created out-of-band.  All deployments reference this storage account to either store state or reference variables from other parts of the deployment however you may choose to use other tools for state managment, like Terraform Cloud after making the necessary code changes.

## Getting Started

This section is organized using folders that match the steps outlined below. Make any necessary adjustments to the variables and settings within that folder to match the needs of your deployment.

### Prerequisites

Clone this repo, install Azure CLI, install Terraform.

[Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### Create terraform.tfvars file

An Azure AD group is required for the SQL Admins. The group must be created before running the Terraform code. This is the minimum required information for the terraform.tfvars file that needs to be created in this folder:

```bash
tenant_id                 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
aad_admin_group_object_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
aad_admin_group_name      = "Azure AD SQL Admins"
```

### Deploy the App Service Landing Zone Terraform code

```bash
terraform init --upgrade
terraform plan
terraform apply --auto-approve
```

Take note of the output values from the Terraform deployment. These will be used in the next steps.

### Approve the App Service private endpoint connection from Front Door in the Azure Portal

This is a manual step that is required to complete the private endpoint connection.

```bash
# Update the resource group name to match the one used in the deployment of the webapp
rg_name="rg-secure-baseline-dev"
webapp_id=$(az webapp list -g $rg_name --query "[].id" -o tsv)
fd_conn_id=$(az network private-endpoint-connection list --id $webapp_id --query "[?properties.provisioningState == 'Pending'].{id:id}" -o tsv)
az network private-endpoint-connection approve --id $fd_conn_id --description "Approved"
```

### Connect to the DevOps VM

From a PowerShell terminal, connect to the DevOps VM using your AAD credentials. The exact `az network bastion rdp` command will be provided in the output of the Terraform deployment.

```bash
az upgrade
az network bastion rdp --name bast-bastion --resource-group rg-hub --target-resource-id /subscriptions/{subscription-id}}/resourceGroups/{rg-name}/providers/Microsoft.Compute/virtualMachines/{vm-name} --disable-gateway
```

From SQL Management Studio, connect to the SQL Server using the SQL Admins group. The user needs to have the format `AzureAD\<user@domain.com>`.

The Azure AD enrollment can take a few minutes to complete. Check: [https://portal.manage-beta.microsoft.com/devices](https://portal.manage-beta.microsoft.com/devices)

If your organization requires device enrollment before accessing corporate resources (i.e. if you see an error "You can't get there from here." or "This device does not meet your organization's compliance requirements"), enroll the Jumpbox to Azure AD by following the steps in Edge: open Edge and click "Sign in to sync data", select "Work or school account", and then press OK on "Allow my organization to manage my device". It takes a few minutes for the policies to be applied, device scanned and confirmed as secure to access corporate resources. You will know that the process is complete.

Once completed, you should be able to connect to the SQL Server using the Azure AD account. On the sample database (sample-db), run the following commands to create the user and grant minimal permissions (the exact command will be provided in the output of the Terraform deployment):

```sql
CREATE USER [web-app-name] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [web-app-name];
ALTER ROLE db_datawriter ADD MEMBER [web-app-name];
ALTER ROLE db_ddladmin ADD MEMBER [web-app-name];
GO

CREATE USER [web-app-name/slots/slot-name] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [web-app-name/slots/slot-name];
ALTER ROLE db_datawriter ADD MEMBER [web-app-name/slots/slot-name];
ALTER ROLE db_ddladmin ADD MEMBER [web-app-name/slots/slot-name];
GO
```

### Retrieve the Azure Front Door frontend endpoint URL and test the App Service

```bash
az network front-door frontend-endpoint show --front-door-name <front-door-name> --name <front-door-frontend-endpoint-name> --resource-group <front-door-resource-group>```  
```

## TBD: Deploying App Service into Existing Infrastructure

The steps above assume that you will be creating the Hub and Spoke (Landing Zone) Network and supporting components using the code provided, where each step refers to state file information from the previous steps.

To deploy App Service into an existing network, use the [App Service for Existing Cluster](./07-App Service-cluster-existing-infra) folder.  Update the "existing-infra.variables.tf" file to reference the names and resource IDs of the pre-existing infrastructure.
