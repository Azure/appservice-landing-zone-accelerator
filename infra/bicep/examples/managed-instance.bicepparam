// ============================================================================
// Managed Instance — Windows Managed Instance Deployment
// ============================================================================
//
// Deploys a Windows Managed Instance (custom-mode App Service Plan) with
// dedicated VM, RDP access, and customer-provided storage. Connected to an
// ALZ Platform Landing Zone hub via VNet peering and firewall egress.
//
// Deploy with:
//   az deployment sub create \
//     --location eastus2 \
//     --template-file ../main.bicep \
//     --parameters managed-instance.bicepparam
//
// ============================================================================

using '../main.bicep'

// ---------- Workload identity ----------

param workloadName = 'mgdinst'
param location = 'eastus2'
param environmentName = 'prod'

param logAnalyticsWorkspaceResourceId = '/subscriptions/<subscription-id>/resourceGroups/rg-alz-logging/providers/Microsoft.OperationalInsights/workspaces/law-alz-central'

// ---------- Tags (ALZ compliant) ----------

param tags = {
  environment: 'prod'
  workload: 'managed-instance-app'
  deployed_by: 'bicep-alz'
  cost_center: 'IT-Operations'
}

// ---------- Resource Group ----------

param resourceGroupName = 'rg-mgdinst-prod'

// ---------- Hub integration (ALZ Platform Landing Zone) ----------

param hubVnetResourceId = '/subscriptions/<hub-subscription-id>/resourceGroups/rg-hub-networking/providers/Microsoft.Network/virtualNetworks/vnet-hub'
param firewallInternalIp = '10.0.0.4'

// ---------- Spoke network ----------

param spokeVnetAddressSpace = '10.241.0.0/20'
param spokeAppSvcSubnetAddressSpace = '10.241.0.0/26'
param spokePrivateEndpointSubnetAddressSpace = '10.241.11.0/24'

// ---------- App Service Plan (Windows Managed Instance) ----------

param appServicePlanSku = 'P1V3'
param appServicePlanOs = 'windows'
param appServicePlanZoneRedundant = true
param appServicePlanCustomMode = true

// ---------- Web App ----------

param appServiceKind = 'app'
param storageAccountRequired = true
