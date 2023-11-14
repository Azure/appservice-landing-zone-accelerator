# Multitenant App Service Secure Baseline - ARM Implementation
You can deploy the current LZA directly in your azure subscription by hitting the button below. 

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fappservice-landing-zone-accelerator%2Fmain%2Fscenarios%2Fsecure-baseline-multitenant%2Fazure-resource-manager%2Fmain.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fappservice-landing-zone-accelerator%2Fmain%2Fscenarios%2Fsecure-baseline-multitenant%2Fazure-resource-manager%2Fmain-portal-ux.json)


Alternatively, you can clone the repo and follow the instractions below

## Prerequisites 
- Clone this repo
- Install [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)



## Deploy the App Service Landing Zone ARM template file
Before deploying the Bicep IaC artifacts, you need to review and customize the values of the parameters in the [main.parameters.jsonc](main.parameters.jsonc) file. 

The table below summarizes the available parameters and the possible values that can be set. 


| Name | Description | Example | 
|------|-------------|---------|
|workloadName|A suffix that will be used to name the resources in a pattern similar to ` <resourceAbbreviation>-<workloadName> ` . Must be up to 10 characters long, alphanumeric with dashes|app-svc-01|
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
|webAppPlanSku|Defines the name, tier, size, family and capacity of the App Service Plan. Plans ending to _AZ, are deploying at least three instances in three Availability Zones. select one from: 'S1', 'S2', 'S3', 'P1V3', 'P2V3', 'P3V3', 'P1V3_AZ', 'P2V3_AZ', 'P3V3_AZ', 'EP1', 'EP2', 'EP3', 'ASE_I1V2_AZ', 'ASE_I2V2_AZ', 'ASE_I3V2_AZ', 'ASE_I1V2', 'ASE_I2V2', 'ASE_I3V2' | ASE_I1V2_AZ is used only when deployAseV3=true|
|webAppBaseOs|The OS for the App service plan. Two options available: Windows or Linux||
|resourceTags|Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)|"resourceTags": {<br>         "value": { <br>               "deployment": "bicep", <br>  "key1": "value1" <br>           } <br>         } |
|enableEgressLockdown|Feature Flag: te (or not) a UDR for the App Service Subnet, to route all egress traffic through Hub Azure Firewall|
|deployRedis|Feature Flag: Deploy (or not) a redis cache |
|deployAzureSql|Feature Flag: Deploy (or not) an Azure SQL with default database|
|deployAppConfig|Feature Flag: Deploy (or not) an Azure app configuration|
|deployJumpHost|Feature Flag: Deploy (or not) an Azure virtual machine (to be used as jumphost)|
|deployOpenAi|Feature Flag: Deploy (or not) an Azure OpenAI account. ATTENTION: At the time of writing, [OpenAI is in preview](https://learn.microsoft.com/azure/ai-services/openai/chatgpt-quickstart#prerequisites) and available in limited regions. |false
|sqlServerAdministrators|The Azure Active Directory (AAD) administrator group used for SQL Server authentication.  The Azure AD group  must be created before running deployment. This has three values that need to be filled, as shown below <br> **login**: the name of the AAD Group <br> **sid**: the object id  of the AAD Group <br> **tenantId**: The tenantId of the AAD ||

After the parameters have been initialized, you can deploy the Landing Zone Accelerator resources with the following `az cli` command:

### Bash shell (i.e. inside WSL2 for windows 11, or any linux-based OS)
``` bash
location=northeurope # or any location that suits your needs
deploymentName=bicepAppSvcLzaDeployment  # or any other value that suits your needs

az deployment sub create \
    --template-file main.bicep \
    --location $location \
    --name $deploymentName \
    --parameters ./main.parameters.jsonc
```

### Powershell (windows based OS)
``` powershell
$location=northeurope # or any location that suits your needs
$deploymentName=bicepAppSvcLzaDeployment  # or any other value that suits your needs

az deployment sub create `
    --template-file main.bicep `
    --location $location `
    --name $deploymentName `
    --parameters ./main.parameters.jsonc
```

   
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

### Connect to the Jumpbox VM (deployed in the spoke resource group)

You can connect to the jumpbox win 11 VM only through bastion. The default parameters deploy a Bastion in Standard SKU, with native client support enabled. The jumpbox VM is AADJoined by default. This means that you can connect to the jumpbox, either with the local user/password compination (azureuser is the default username) or with a valid AAD account. In certain circumastances your organization may not allow the device to be enrolled. If the jumpbox VM is AAD joined and properly intune enrolled, you can use native rdp client to connect by running the below Az CLI commands 

From a PowerShell terminal, connect to the DevOps VM using your Azure AD credentials (or Windows Hello). 

```powershell
az upgrade

az login
az account list
az account set --subscription "<subscription ID>"

az network bastion rdp --name bast-bastion --resource-group rg-hub --target-resource-id /subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.Compute/virtualMachines/{vm-name} --disable-gateway
```

More  details on how to [connect to a windows VM with native rdp client, can be found here](https://learn.microsoft.com/en-us/azure/bastion/connect-native-client-windows#connect-windows)

The Azure AD enrollment can take a few minutes to complete. Check: [https://portal.manage-beta.microsoft.com/devices](https://portal.manage-beta.microsoft.com/devices)

If your organization requires device enrollment before accessing corporate resources (i.e. if you see an error "You can't get there from here." or "This device does not meet your organization's compliance requirements"),login to the VM with local user (i.e. azureuser) and enroll the Jumpbox to Azure AD by following the steps in Edge: 
- open Edge and click "Sign in to sync data", 
- select "Work or school account", 
- and then press OK on "Allow my organization to manage my device". 

It takes a few minutes for the policies to be applied, device scanned and confirmed as secure to access corporate resources. You will know that the process is complete.

If you experience issues connecting to the DevOps VM using your AAD credentials, see [Unable to connect to DevOps VM using AAD credentials](../terraform/README.md#unable-to-connect-to-devops-vm-using-aad-credentials)

Once completed, and if you provided a valid (AAD) administrator group used for SQL Server authentication (and not only local SQL user administrator), you should be able to connect to the SQL Server using the Azure AD account from SQL Server Management Studio. On the sample database (sample-db by default), run the following commands to create the user and grant minimal permissions:

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
