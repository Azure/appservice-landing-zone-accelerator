// ============================================================================
// App Service Plan — Windows Container Web App
// ============================================================================
//
// Deploys a multitenant App Service Plan with a Windows container web app.
// Includes ACR integration for pulling container images. No ASE — uses
// shared infrastructure. Connected to an ALZ Platform Landing Zone hub
// via VNet peering with firewall egress lockdown.
//
// Deploy with:
//   az deployment sub create \
//     --location eastus2 \
//     --template-file ../main.bicep \
//     --parameters asp-windows-container.bicepparam
//
// ============================================================================

using '../main.bicep'

// ---------- Workload identity ----------

param workloadName = 'wincont'
param location = 'eastus2'
param environmentName = 'prod'

param logAnalyticsWorkspaceResourceId = '/subscriptions/<subscription-id>/resourceGroups/rg-alz-logging/providers/Microsoft.OperationalInsights/workspaces/law-alz-central'

// ---------- Tags (ALZ compliant) ----------

param tags = {
  environment: 'prod'
  workload: 'asp-windows-container'
  deployed_by: 'bicep-alz'
  cost_center: 'Product'
}

// ---------- Resource Group ----------

param resourceGroupName = 'rg-wincont-prod'

// ---------- Hub integration (ALZ Platform Landing Zone) ----------

param hubVnetResourceId = '/subscriptions/<hub-subscription-id>/resourceGroups/rg-hub-networking/providers/Microsoft.Network/virtualNetworks/vnet-hub'
param firewallInternalIp = '10.0.0.4'

// ---------- Spoke network ----------

param spokeVnetAddressSpace = '10.247.0.0/20'
param spokeAppSvcSubnetAddressSpace = '10.247.0.0/26'
param spokePrivateEndpointSubnetAddressSpace = '10.247.11.0/24'

// ---------- App Service Plan (Premium V3 with Hyper-V for Windows containers) ----------

param appServicePlanSku = 'P1V3'
param appServicePlanOs = 'windows'
param appServicePlanZoneRedundant = true

// ---------- Web App (Windows container) ----------

param appServiceKind = 'app,container,windows'

// ---------- Container registry (ACR) ----------

param containerImageName = 'myregistry.azurecr.io/myapp/dotnet-service:v1.0'
param containerRegistryUrl = 'https://myregistry.azurecr.io'
