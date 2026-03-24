// ============================================================================
// ASE v3 — Linux Container Web App
// ============================================================================
//
// Deploys an App Service Environment v3 with a Linux container web app.
// Includes ACR integration for pulling container images. Connected to an
// ALZ Platform Landing Zone hub via VNet peering with firewall egress lockdown.
//
// Deploy with:
//   az deployment sub create \
//     --location eastus2 \
//     --template-file ../main.bicep \
//     --parameters ase-linux-container.bicepparam
//
// ============================================================================

using '../main.bicep'

// ---------- Workload identity ----------

param workloadName = 'aselcont'
param location = 'eastus2'
param environmentName = 'prod'

param logAnalyticsWorkspaceResourceId = '/subscriptions/<subscription-id>/resourceGroups/rg-alz-logging/providers/Microsoft.OperationalInsights/workspaces/law-alz-central'

// ---------- Tags (ALZ compliant) ----------

param tags = {
  environment: 'prod'
  workload: 'ase-linux-container'
  deployed_by: 'bicep-alz'
  cost_center: 'Engineering'
}

// ---------- Resource Group ----------

param resourceGroupName = 'rg-aselcont-prod'

// ---------- Hub integration (ALZ Platform Landing Zone) ----------

param hubVnetResourceId = '/subscriptions/<hub-subscription-id>/resourceGroups/rg-hub-networking/providers/Microsoft.Network/virtualNetworks/vnet-hub'
param firewallInternalIp = '10.0.0.4'

// ---------- ASE v3 ----------

param deployAseV3 = true

// ---------- Spoke network (ASE requires /24 for app subnet) ----------

param spokeVnetAddressSpace = '10.245.0.0/20'
param spokeAppSvcSubnetAddressSpace = '10.245.0.0/24'
param spokePrivateEndpointSubnetAddressSpace = '10.245.11.0/24'

// ---------- App Service Plan (Isolated V2 for ASE) ----------

param appServicePlanSku = 'I1v2'
param appServicePlanOs = 'linux'
param appServicePlanZoneRedundant = true

// ---------- Web App (Linux container) ----------

param appServiceKind = 'app,linux,container'

// ---------- Container registry (ACR) ----------

param containerImageName = 'myregistry.azurecr.io/myapp/api:v2.1'
param containerRegistryUrl = 'https://myregistry.azurecr.io'
