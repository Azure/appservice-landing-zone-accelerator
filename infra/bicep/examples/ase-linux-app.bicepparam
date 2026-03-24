// ============================================================================
// ASE v3 — Linux Code-Based Web App
// ============================================================================
//
// Deploys an App Service Environment v3 with a Linux web app running
// code (e.g. Node.js, Python, .NET on Linux). Connected to an ALZ Platform
// Landing Zone hub via VNet peering with firewall egress lockdown.
//
// Deploy with:
//   az deployment sub create \
//     --location eastus2 \
//     --template-file ../main.bicep \
//     --parameters ase-linux-app.bicepparam
//
// ============================================================================

using '../main.bicep'

// ---------- Workload identity ----------

param workloadName = 'aselapp'
param location = 'eastus2'
param environmentName = 'prod'

param logAnalyticsWorkspaceResourceId = '/subscriptions/<subscription-id>/resourceGroups/rg-alz-logging/providers/Microsoft.OperationalInsights/workspaces/law-alz-central'

// ---------- Tags (ALZ compliant) ----------

param tags = {
  environment: 'prod'
  workload: 'ase-linux-webapp'
  deployed_by: 'bicep-alz'
  cost_center: 'Engineering'
}

// ---------- Resource Group ----------

param resourceGroupName = 'rg-aselapp-prod'

// ---------- Hub integration (ALZ Platform Landing Zone) ----------

param hubVnetResourceId = '/subscriptions/<hub-subscription-id>/resourceGroups/rg-hub-networking/providers/Microsoft.Network/virtualNetworks/vnet-hub'
param firewallInternalIp = '10.0.0.4'

// ---------- ASE v3 ----------

param deployAseV3 = true

// ---------- Spoke network (ASE requires /24 for app subnet) ----------

param spokeVnetAddressSpace = '10.244.0.0/20'
param spokeAppSvcSubnetAddressSpace = '10.244.0.0/24'
param spokePrivateEndpointSubnetAddressSpace = '10.244.11.0/24'

// ---------- App Service Plan (Isolated V2 for ASE) ----------

param appServicePlanSku = 'I1v2'
param appServicePlanOs = 'linux'
param appServicePlanZoneRedundant = true

// ---------- Web App (Linux code-based) ----------

param appServiceKind = 'app,linux'
