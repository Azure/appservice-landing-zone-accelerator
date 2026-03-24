// ============================================================================
// App Service Landing Zone Accelerator — Default Parameters
// ============================================================================
//
// This file provides a minimal, standalone deployment (no hub peering).
// For complete ALZ Platform Landing Zone examples with hub integration,
// container, ASE, and managed instance scenarios, see examples/.
//
// Deploy with:
//   az deployment sub create \
//     --location eastus2 \
//     --template-file main.bicep \
//     --parameters main.bicepparam
//
// ============================================================================

using 'main.bicep'

// ---------- Required ----------

param workloadName = 'appsvc'
param location = 'eastus2'
param environmentName = 'dev'

// Log Analytics workspace provisioned by the platform team or ALZ IaC Accelerator.
// Replace with your own workspace resource ID.
param logAnalyticsWorkspaceResourceId = '/subscriptions/<subscription-id>/resourceGroups/<rg-name>/providers/Microsoft.OperationalInsights/workspaces/<workspace-name>'

// ---------- Tags ----------

param tags = {
  environment: 'dev'
  workload: 'app-service-lza'
  deployed_by: 'bicep'
}

// ---------- Resource Group ----------

param resourceGroupName = 'rg-appsvc-dev'

// ---------- Spoke network ----------

param spokeVnetAddressSpace = '10.240.0.0/20'
param spokeAppSvcSubnetAddressSpace = '10.240.0.0/26'
param spokePrivateEndpointSubnetAddressSpace = '10.240.11.0/24'

// ---------- App Service ----------

param appServicePlanSku = 'P1V3'
param appServicePlanOs = 'windows'
param appServicePlanZoneRedundant = true
