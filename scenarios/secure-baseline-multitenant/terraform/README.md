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

1. Clone this repository.
2. [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
3. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### Create terraform.tfvars file

An Azure AD user for the DevOps VM admin account and an Azure AD group is required for the SQL Admins. The group must be created before running the Terraform code. This is the minimum required information for the `terraform.tfvars` file that can be created in the [solutions](./solutions) folder.:

```bash
application_name = "secure-webapp"
environment      = "prod"
location         = "swedencentral"
location_short   = "swe"

tenant_id                 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
aad_admin_group_object_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
aad_admin_group_name      = "Azure AD SQL Admins"
vm_aad_admin_username     = "bob@contoso.com"

# Optionally provide non-AAD admin credentials for the VM
# vm_admin_username         = "daniem"
# vm_admin_password         = "**************"

# These settings are used for peering the spoke to the hub. Fill in the appropriate settings for your environment
hub_settings = {
  rg_name   = "_hub_rg_name_"
  vnet_name = "_hub_vnet_name_"

  firewall = {
    private_ip = "x.x.x.x"
  }
}

# Toggle deployment of optional features and services for the Landing Zone
deployment_options = {
  enable_waf                 = true
  enable_egress_lockdown     = true
  enable_diagnostic_settings = true
  deploy_bastion             = true
  deploy_redis               = true
  deploy_sql_database        = true
  deploy_app_config          = true
  deploy_vm                  = true
}

# Optionally deploy a Github runner, DevOps agent, or both to the VM. 
# devops_settings = {
#   github_runner = {
#     repository_url = "https://github.com/{organization}/{repository}"
#     token          = "runner_registration_token" # See: https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28
#   }
# 
#   devops_agent = {
#     organization_url = "https://dev.azure.com/{organization}/"
#     token            = "pat_token"
#   }
# }

appsvc_options = {
  service_plan = {
    os_type        = "Windows"
    sku_name       = "S1"

    # Optionally configure zone redundancy (requires a minimum of three workers and Premium SKU service plan) 
    # worker_count   = 3
    # zone_redundant = true
  }

  web_app = {

    application_stack = {
      current_stack  = "dotnet"
      dotnet_version = "v6.0"
    }

    slots = ["staging"]
  }
}
```

### Deploy the Hub (optional)
In case you already have a pre-existing hub that you want to connect to, you can skip to the next step. 

```bash
cd ./scenarios/secure-baseline-multitenant/terraform/solutions/hub

terraform init --upgrade
terraform plan --var-file="../terraform.tfvars"
terraform apply --auto-approve --var-file="../terraform.tfvars"
```

> **Warning**
> If using a pre-existing Hub or firewall, make sure all the necessary firewall rules are in place. Review the [firewall rules created for the reference implementation](./modules/firewall/main.tf).

### Deploy the Spoke
Update the `hub_settings` section of the `terraform.tfvars` file with the appropriate values for your environemnt, e.g.: 

```bash
hub_settings = {
  rg_name   = "rg-hub-swe"
  vnet_name = "vnet-hub-swe"

  firewall = {
    private_ip = "10.242.0.4"
  }
}
```

Run the terraform deployment for the spoke: 

```bash
cd ./scenarios/secure-baseline-multitenant/terraform/solutions/spoke

terraform init --upgrade
terraform plan --var-file="../terraform.tfvars"
terraform apply --auto-approve --var-file="../terraform.tfvars"
```

Take note of the output values from the Terraform deployment. These will be used in the next steps.

### Approve the App Service private endpoint connection from Front Door in the Azure Portal

This is a manual step that is required to complete the private endpoint connection.

```bash
# Update the resource group name to match the one used in the deployment of the webapp
rg_name="rg-spoke-appsvclza1-dev-northeurope"
webapp_ids=$(az webapp list -g $rg_name --query "[].id" -o tsv)

# you might have more than one web apps, check for all of them if there are pending approvals
for webapp_id in $webapp_ids; do
    # there might be more than one pending connection per web app
    fd_conn_ids=$(az network private-endpoint-connection list --id $webapp_id --query "[?properties.provisioningState == 'Pending'].id" -o tsv)
    
    for fd_conn_id in $fd_conn_ids; do
        az network private-endpoint-connection approve --id "$fd_conn_id" --description "Approved"
    done
done
```

### Connect to the DevOps VM

From a PowerShell terminal, connect to the DevOps VM using your Azure AD credentials (or Windows Hello). The exact `az network bastion rdp` command will be provided in the output of the Terraform deployment.

```powershell
az upgrade
az network bastion rdp --name bast-bastion --resource-group rg-hub --target-resource-id /subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.Compute/virtualMachines/{vm-name} --disable-gateway
```

If you experience issues connecting to the DevOps VM using your AAD credentials, see [Unable to connect to DevOps VM using AAD credentials](#unable-to-connect-to-devops-vm-using-aad-credentials)

Once completed, you should be able to connect to the SQL Server using the Azure AD account from SQL Server Management Studio. On the sample database (sample-db by default), run the following commands to create the user and grant minimal permissions (the exact command will be provided in the output of the Terraform deployment):

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

From a PowerShell terminal in your DevOps VM, you'll need to add a Key Vault secret for Redis Cache connection string by executing `az keyvault secret set`. The exact command will be provided in the output of the Terraform deployment (terraform output -raw cmd_redis_connection_kvsecret).

```powershell
az keyvault secret set --vault-name <keyvault-name> --name <kv-secret-name> --value <redis-cache-connection-string>
```

### Retrieve the Azure Front Door frontend endpoint URL and test the App Service

```bash
az network front-door frontend-endpoint show --front-door-name <front-door-name> --name <front-door-frontend-endpoint-name> --resource-group <front-door-resource-group>  
```

## Troubleshooting

### Unable to connect to DevOps VM using AAD credentials
The Azure AD enrollment can take a few minutes to complete. Check: [https://portal.manage-beta.microsoft.com/devices](https://portal.manage-beta.microsoft.com/devices)

Verify in the Azure Portal if the `aad-login-for-windows` VM extension was deployed successfully. 

Connect to the VM using the local VM admin credentials and run `dsregcmd /status`. The output should look similar to this:

```bash
+----------------------------------------------------------------------+
| Device State                                                         |
+----------------------------------------------------------------------+

             AzureAdJoined : YES
          EnterpriseJoined : NO
              DomainJoined : NO
           Virtual Desktop : NOT SET
               Device Name : vm-devops-1953

+----------------------------------------------------------------------+
| Device Details                                                       |
+----------------------------------------------------------------------+

                  DeviceId : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
                Thumbprint : 6C226302696DF************************
 DeviceCertificateValidity : [ 2023-03-29 11:03:56.000 UTC -- 2033-03-29 11:33:56.000 UTC ]
            KeyContainerId : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
               KeyProvider : Microsoft Software Key Storage Provider
              TpmProtected : NO
          DeviceAuthStatus : SUCCESS

+----------------------------------------------------------------------+
| Tenant Details                                                       |
+----------------------------------------------------------------------+

                TenantName :
                  TenantId : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
               AuthCodeUrl : https://login.microsoftonline.com/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/oauth2/authorize
            AccessTokenUrl : https://login.microsoftonline.com/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/oauth2/token
                    MdmUrl :
                 MdmTouUrl :
          MdmComplianceUrl :
               SettingsUrl :
            JoinSrvVersion : 2.0
                JoinSrvUrl : https://enterpriseregistration.windows.net/EnrollmentServer/device/
                 JoinSrvId : urn:ms-drs:enterpriseregistration.windows.net
             KeySrvVersion : 1.0
                 KeySrvUrl : https://enterpriseregistration.windows.net/EnrollmentServer/key/
                  KeySrvId : urn:ms-drs:enterpriseregistration.windows.net
        WebAuthNSrvVersion : 1.0
            WebAuthNSrvUrl : https://enterpriseregistration.windows.net/webauthn/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/
             WebAuthNSrvId : urn:ms-drs:enterpriseregistration.windows.net
    DeviceManagementSrvVer : 1.0
    DeviceManagementSrvUrl : https://enterpriseregistration.windows.net/manage/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/
     DeviceManagementSrvId : urn:ms-drs:enterpriseregistration.windows.net
```

If the VM is AAD joined, try to login in with the Azure AD credentials again after a few minutes. If it's not AAD joined, attempt to re-install the VM extension or manually enroll the VM to AAD by following the steps in Edge: open Edge and click "Sign in to sync data", select "Work or school account", and then press OK on "Allow my organization to manage my device". It takes a few minutes for the policies to be applied, device scanned and confirmed as secure to access corporate resources. You will know that the process is complete.


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.2 |
| <a name="requirement_azurecaf"></a> [azurecaf](#requirement\_azurecaf) | >=1.2.22 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.34.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.40.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_hub"></a> [hub](#module\_hub) | ./modules/hub | n/a |
| <a name="module_spoke"></a> [spoke](#module\_spoke) | ./modules/spoke | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_network_peering.hub_to_spoke](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.spoke_to_hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aad_admin_group_name"></a> [aad\_admin\_group\_name](#input\_aad\_admin\_group\_name) | The name of the Azure AD group that should be granted SQL Admin permissions to the SQL Server | `string` | n/a | yes |
| <a name="input_aad_admin_group_object_id"></a> [aad\_admin\_group\_object\_id](#input\_aad\_admin\_group\_object\_id) | The object ID of the Azure AD group that should be granted SQL Admin permissions to the SQL Server | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name of your application | `string` | `"secure-baseline"` | no |
| <a name="input_appsvc_int_subnet_cidr"></a> [appsvc\_int\_subnet\_cidr](#input\_appsvc\_int\_subnet\_cidr) | The CIDR block for the subnet. | `list(string)` | `null` | no |
| <a name="input_bastion_subnet_cidr"></a> [bastion\_subnet\_cidr](#input\_bastion\_subnet\_cidr) | The CIDR block for the bastion subnet. | `string` | `null` | no |
| <a name="input_deployment_options"></a> [deployment\_options](#input\_deployment\_options) | Opt-in settings for the deployment: enable WAF in Front Door, deploy Azure Firewall and UDRs in the spoke network to force outbound traffic to the Azure Firewall, deploy Redis Cache. | <pre>object({<br>    enable_waf             = bool<br>    enable_egress_lockdown = bool<br>    deploy_redis           = bool<br>  })</pre> | <pre>{<br>  "deploy_redis": true,<br>  "enable_egress_lockdown": true,<br>  "enable_waf": true<br>}</pre> | no |
| <a name="input_devops_subnet_cidr"></a> [devops\_subnet\_cidr](#input\_devops\_subnet\_cidr) | The CIDR block for the subnet. | `list(string)` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment (dev, qa, staging, prod) | `string` | `"dev"` | no |
| <a name="input_firewall_subnet_cidr"></a> [firewall\_subnet\_cidr](#input\_firewall\_subnet\_cidr) | The CIDR block for the firewall subnet. | `string` | `null` | no |
| <a name="input_front_door_subnet_cidr"></a> [front\_door\_subnet\_cidr](#input\_front\_door\_subnet\_cidr) | The CIDR block for the subnet. | `list(string)` | `null` | no |
| <a name="input_hub_vnet_cidr"></a> [hub\_vnet\_cidr](#input\_hub\_vnet\_cidr) | The CIDR block for the hub virtual network. | `list(string)` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where all resources in this example should be created | `string` | `"westeurope"` | no |
| <a name="input_private_link_subnet_cidr"></a> [private\_link\_subnet\_cidr](#input\_private\_link\_subnet\_cidr) | The CIDR block for the subnet. | `list(string)` | `null` | no |
| <a name="input_spoke_vnet_cidr"></a> [spoke\_vnet\_cidr](#input\_spoke\_vnet\_cidr) | The CIDR block for the virtual network. | `list(string)` | `null` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The Azure AD tenant ID for the identities | `string` | n/a | yes |
| <a name="input_vm_aad_admin_username"></a> [vm\_aad\_admin\_username](#input\_vm\_aad\_admin\_username) | The Azure AD username for the VM admin account. | `string` | n/a | yes |
| <a name="input_vm_admin_password"></a> [vm\_admin\_password](#input\_vm\_admin\_password) | The password for the local VM admin account. Prefer using the Azure AD admin account. | `string` | `null` | no |
| <a name="input_vm_admin_username"></a> [vm\_admin\_username](#input\_vm\_admin\_username) | The username for the local VM admin account. Prefer using the Azure AD admin account. | `string` | `null` | no |
| <a name="input_webapp_slot_name"></a> [webapp\_slot\_name](#input\_webapp\_slot\_name) | The name of the app service slot | `string` | `"deployment"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cmd_devops_vm_rdp"></a> [cmd\_devops\_vm\_rdp](#output\_cmd\_devops\_vm\_rdp) | n/a |
| <a name="output_cmd_grant_sql_permissions"></a> [cmd\_grant\_sql\_permissions](#output\_cmd\_grant\_sql\_permissions) | n/a |
| <a name="output_cmd_redis_connection_kvsecret"></a> [cmd\_redis\_connection\_kvsecret](#output\_cmd\_redis\_connection\_kvsecret) | n/a |
| <a name="output_cmd_swap_slots"></a> [cmd\_swap\_slots](#output\_cmd\_swap\_slots) | n/a |
| <a name="output_sql_db_connection_string"></a> [sql\_db\_connection\_string](#output\_sql\_db\_connection\_string) | n/a |
| <a name="output_vault_uri"></a> [vault\_uri](#output\_vault\_uri) | n/a |
| <a name="output_web_app_uri"></a> [web\_app\_uri](#output\_web\_app\_uri) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
