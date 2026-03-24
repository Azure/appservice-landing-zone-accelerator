// ============================================================================
// App Service Plan — Linux Container Web App
// ============================================================================
//
// Deploys a multitenant App Service Plan with a Linux container web app.
// Includes ACR integration for pulling container images. No ASE — uses
// shared infrastructure. Connected to an ALZ Platform Landing Zone hub
// via VNet peering with firewall egress lockdown.
//
// Deploy with:
//   az deployment sub create \
//     --location eastus2 \
//     --template-file ../main.bicep \
//     --parameters asp-linux-container.bicepparam
//
// ============================================================================

using '../main.bicep'

// ---------- Workload identity ----------

param workloadName = 'lnxcont'
param location = 'eastus2'
param environmentName = 'prod'

param logAnalyticsWorkspaceResourceId = '/subscriptions/<subscription-id>/resourceGroups/rg-alz-logging/providers/Microsoft.OperationalInsights/workspaces/law-alz-central'

// ---------- Tags (ALZ compliant) ----------

param tags = {
  environment: 'prod'
  workload: 'asp-linux-container'
  deployed_by: 'bicep-alz'
  cost_center: 'Product'
}

// ---------- Resource Group ----------

param resourceGroupName = 'rg-lnxcont-prod'

// ---------- Hub integration (ALZ Platform Landing Zone) ----------

param hubVnetResourceId = '/subscriptions/<hub-subscription-id>/resourceGroups/rg-hub-networking/providers/Microsoft.Network/virtualNetworks/vnet-hub'
param firewallInternalIp = '10.0.0.4'

// ---------- Spoke network ----------

param spokeVnetAddressSpace = '10.249.0.0/20'
param spokeAppSvcSubnetAddressSpace = '10.249.0.0/26'
param spokePrivateEndpointSubnetAddressSpace = '10.249.11.0/24'

// ---------- App Service Plan (Premium V3) ----------

param appServicePlanSku = 'P1V3'
param appServicePlanOs = 'linux'
param appServicePlanZoneRedundant = true

// ---------- Web App (Linux container) ----------

param appServiceKind = 'app,linux,container'

// ---------- Container registry (ACR) ----------

param containerImageName = 'myregistry.azurecr.io/myapp/node-api:v3.0'
param containerRegistryUrl = 'https://myregistry.azurecr.io'
