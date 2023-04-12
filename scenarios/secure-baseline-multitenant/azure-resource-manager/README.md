# Multitenant App Service Secure Baseline - ARM Implementation
You can deploy the current LZA directly in your azure subscription by hitting the button below. 

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fappservice-landing-zone-accelerator%2Ffeat%2Fbicep-refactor-multitenant-secure-baseline%2Fscenarios%2Fsecure-baseline-multitenant%2Fazure-resource-manager%2Fmain.json)

Alternatively, you can clone the repo and follow the instractions below

## Prerequisites 
- Clone this repo
- Install [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)



## Deploy the App Service Landing Zone ARM template file
Before deploying the ARM IaC artifacts, you need to review and customize the values of the parameters in the [main.parameters.jsonc](main.parameters.jsonc) file. 

The table below summurizes the avaialble parameters and the possible values that can be set. 


| Name | Description | Example | 
|------|-------------|---------|
|applicationName|A suffix that will be used to name the resources in a pattern similar to ` <resourceAbbreviation>-<applicationName> ` . Must be up to 10 characters long, alphanumeric with dashes|app-svc-01|
|location|Azure region where the resources will be deployed in||
|environment|Required. The name of the environment (e.g. "dev", "test", "prod", "preprod", "staging", "uat", "dr", "qa"). Up to 8 characters long.||
|vnetHubResourceId|If empty, then a new hub will be created. If you select not to deploy a new Hub resource group, set the resource id of the Hub Virtual Network that you want to peer to. In that case, no new hub will be created and a peering will be created between the new spoke and and existing hub vnet|/subscriptions/<subscription_id>/ resourceGroups/<rg_name>/providers/ Microsoft.Network/virtualNetworks/<vnet_name>|
|firewallInternalIp|If you select to create a new Hub, the UDR for locking the egress traffic will be created as well, no matter what value you set to that variable. However, if you select to connect to an existing hub, then you need to provide the internal IP of the azure firewal so that the deployment can create the UDR for locking down egress traffic. If not given, no UDR will be created||
|vnetHubAddressSpace|If you deploy a new hub, you need to set the appropriate CIDR of the newly created Hub virtual network|10.242.0.0/20|
|subnetHubFirewallAddressSpace|CIDR of the subnet that will host the azure Firewall|10.242.0.0/26|
|subnetHubBastionAddressSpace|CIDR of the subnet that will host the Bastion Service|10.242.0.64/26|
|vnetSpokeAddressSpace|CIDR of the spoke vnet that will hold the app services plan and the rest supporting services (and their private endpoints)|10.240.0.0/20|
|subnetSpokeAppSvcAddressSpace|CIDR of the subnet that will hold the app services plan|10.240.0.0/26|
|subnetSpokeDevOpsAddressSpace|CIDR of the subnet that will hold devOps agents etc|10.240.10.128/26|
|subnetSpokePrivateEndpointAddressSpace|CIDR of the subnet that will hold the private endpoints of the supporting services|10.240.11.0/24|
|webAppPlanSku|Defines the name, tier, size, family and capacity of the App Service Plan. Plans ending to _AZ, are deplying at least three instances in three Availability Zones. select one from: 'B1', 'B2', 'B3', 'S1', 'S2', 'S3', 'P1V3', 'P2V3', 'P3V3', 'P1V3_AZ', 'P2V3_AZ', 'P3V3_AZ' ||
|webAppBaseOs|The OS for the App service plan. Two options available: Windows or Linux||
|resourceTags|Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)|"resourceTags": {<br>         "value": { <br>               "deployment": "ARM", <br>  "key1": "value1" <br>           } <br>         } |
|deploymentOptions|Several boolean feature flags. Control the deployment or not of auxiliary azure resources. Feature flags are descibed below <br> **enableEgressLockdown**: Create (or not) a UDR for the App Service Subnet, to route all egress traffic through Hub Azure Firewall <br> **deployRedis**: Deploy (or not) a redis cache <br> **deployAzureSql**: Deploy (or not) an Azure SQL with default database <br> **deployAppConfig**: Deploy (or not) an Azure app configuration <br> **deployJumpHost**: Deploy (or not) an Azure virtual machine (to be used as jumphost) ||
|sqlServerAdministrators|The Azure Active Directory (AAD) administrator group used for SQL Server authentication.  The Azure AD group  must be created before running deployment. This has three values that need to be filled, as shown below <br> **login**: the name of the AAD Group <br> **sid**: the object id  of the AAD Group <br> **tenantId**: The tenantId of the AAD ||

After the parameters have been initialized, you can deploy the Landing Zone Accelerator resources with the following `az cli` command:

### Bash shell (i.e. inside WSL2 for windows 11, or any linux-based OS)
``` bash
location=northeurope # or any location that suits your needs
deploymentName=armAppSvcLzaDeployment  # or any other value that suits your needs

az deployment sub create \
    --template-file main.json \
    --location $location \
    --name $deploymentName \
    --parameters ./main.parameters.local.jsonc
```

### Powershell (windows based OS)
``` powershell
$location=northeurope # or any location that suits your needs
$deploymentName=armAppSvcLzaDeployment  # or any other value that suits your needs

az deployment sub create `
    --template-file main.arm `
    --location $location `
    --name $deploymentName `
    --parameters ./main.parameters.local.jsonc
```

   

### Approve the App Service private endpoint connection from Front Door in the Azure Portal

This is a manual step that is required to complete the private endpoint connection.

### Retrieve the Azure Front Door frontend endpoint URL and test the App Service

```bash
az network front-door frontend-endpoint show --front-door-name <front-door-name> --name <front-door-frontend-endpoint-name> --resource-group <front-door-resource-group>  
```

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

From a PowerShell terminal, connect to the DevOps VM using your Azure AD credentials (or Windows Hello). The exact `az network bastion rdp` command will be provided in the output of the Terraform deployment.

```powershell
az upgrade
az network bastion rdp --name bast-bastion --resource-group rg-hub --target-resource-id /subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.Compute/virtualMachines/{vm-name} --disable-gateway
```

The Azure AD enrollment can take a few minutes to complete. Check: [https://portal.manage-beta.microsoft.com/devices](https://portal.manage-beta.microsoft.com/devices)

If your organization requires device enrollment before accessing corporate resources (i.e. if you see an error "You can't get there from here." or "This device does not meet your organization's compliance requirements"), enroll the Jumpbox to Azure AD by following the steps in Edge: open Edge and click "Sign in to sync data", select "Work or school account", and then press OK on "Allow my organization to manage my device". It takes a few minutes for the policies to be applied, device scanned and confirmed as secure to access corporate resources. You will know that the process is complete.

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
