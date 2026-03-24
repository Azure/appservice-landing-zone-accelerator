// ============================================================================
// ASE v3 — Windows Container Web App
// ============================================================================
//
// Deploys an App Service Environment v3 with a Windows container web app.
// Includes ACR integration for pulling container images. Connected to an
// ALZ Platform Landing Zone hub via VNet peering with firewall egress lockdown.
//
// Deploy with:
//   az deployment sub create \
//     --location eastus2 \
//     --template-file ../main.bicep \
//     --parameters ase-windows-container.bicepparam
//
// ============================================================================

using '../main.bicep'

// ---------- Workload identity ----------

param workloadName = 'asewcont'
param location = 'eastus2'
param environmentName = 'prod'

param logAnalyticsWorkspaceResourceId = '/subscriptions/<subscription-id>/resourceGroups/rg-alz-logging/providers/Microsoft.OperationalInsights/workspaces/law-alz-central'

// ---------- Tags (ALZ compliant) ----------

param tags = {
  environment: 'prod'
  workload: 'ase-windows-container'
  deployed_by: 'bicep-alz'
  cost_center: 'Engineering'
}

// ---------- Resource Group ----------

param resourceGroupName = 'rg-asewcont-prod'

// ---------- Hub integration (ALZ Platform Landing Zone) ----------

param hubVnetResourceId = '/subscriptions/<hub-subscription-id>/resourceGroups/rg-hub-networking/providers/Microsoft.Network/virtualNetworks/vnet-hub'
param firewallInternalIp = '10.0.0.4'

// ---------- ASE v3 ----------

param deployAseV3 = true

// ---------- Spoke network (ASE requires /24 for app subnet) ----------

param spokeVnetAddressSpace = '10.243.0.0/20'
param spokeAppSvcSubnetAddressSpace = '10.243.0.0/24'
param spokePrivateEndpointSubnetAddressSpace = '10.243.11.0/24'

// ---------- App Service Plan (Isolated V2 for ASE) ----------

param appServicePlanSku = 'I1v2'
param appServicePlanOs = 'windows'
param appServicePlanZoneRedundant = true

// ---------- Web App (Windows container) ----------

param appServiceKind = 'app,container,windows'

// ---------- Container registry (ACR) ----------

param containerImageName = 'myregistry.azurecr.io/myapp/windows-service:v1.0'
param containerRegistryUrl = 'https://myregistry.azurecr.io'
