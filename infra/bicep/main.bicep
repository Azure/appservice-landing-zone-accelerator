// ============================================================================
// App Service Landing Zone Accelerator — Spoke Deployment
// ============================================================================
//
// This template deploys the App Service workload spoke using the AVM pattern
// module. It does NOT deploy hub networking — users should provision their hub
// via the ALZ IaC Accelerator (https://aka.ms/alz/acc) and optionally connect
// it through the hub peering parameters below.
//
// Supported hosting models:
//   - Multitenant App Service Plan (Windows/Linux, code or container)
//   - App Service Environment v3 (Windows/Linux, code or container)
//   - Windows Managed Instance (custom mode with RDP / storage)
//
// Deployment scope: Subscription
//   az deployment sub create --location <region> --template-file main.bicep --parameters main.bicepparam
//
// See infra/bicep/examples/ for ready-to-deploy parameter files.
//
// ============================================================================

targetScope = 'subscription'

// ======================== //
// Parameters               //
// ======================== //

@maxLength(10)
@description('Short name for the workload (max 10 chars). Used as a prefix in resource names.')
param workloadName string

@description('Azure region for the deployment.')
param location string = deployment().location

@maxLength(8)
@description('Environment label (e.g. "dev", "test", "prod"). Used in resource naming.')
param environmentName string = 'dev'

@description('Resource ID of a Log Analytics workspace for diagnostic settings. Required by the pattern module.')
param logAnalyticsWorkspaceResourceId string

@description('Tags applied to every resource.')
param tags object = {}

// --- Hub integration (optional — leave empty for standalone spoke) ---

@description('Resource ID of the hub VNet to peer with. Leave empty if no hub exists or peering is handled externally.')
param hubVnetResourceId string = ''

@description('Internal IP of the Azure Firewall in the hub. Set this to route egress through the firewall.')
param firewallInternalIp string = ''

// --- ASE v3 ---

@description('Set to true to deploy an App Service Environment v3 instead of a multitenant App Service Plan.')
param deployAseV3 bool = false

// --- Spoke network ---

@description('CIDR for the spoke VNet.')
param spokeVnetAddressSpace string = '10.240.0.0/20'

@description('CIDR for the App Service integration subnet. ASE v3 requires at least a /24.')
param spokeAppSvcSubnetAddressSpace string = '10.240.0.0/26'

@description('CIDR for the private endpoint subnet.')
param spokePrivateEndpointSubnetAddressSpace string = '10.240.11.0/24'

// --- App Service Plan ---

@description('App Service Plan SKU (e.g. "P1V3", "I1v2" for ASE).')
param appServicePlanSku string = 'P1V3'

@description('OS for the App Service Plan.')
@allowed(['windows', 'linux'])
param appServicePlanOs string = 'windows'

@description('Enable zone redundancy for the App Service Plan.')
param appServicePlanZoneRedundant bool = true

@description('Enable custom mode for Windows Managed Instance deployments (dedicated Windows VM with RDP access).')
param appServicePlanCustomMode bool = false

// --- Web App ---

@description('Kind of web app. Use "app" for Windows code, "app,linux" for Linux code, "app,container,windows" for Windows container, "app,linux,container" for Linux container.')
@allowed(['app', 'app,linux', 'app,container,windows', 'app,linux,container'])
param appServiceKind string = 'app'

@description('Container image name for container deployments (e.g. "mcr.microsoft.com/appsvc/staticsite:latest").')
param containerImageName string = ''

@description('Container registry URL for private registries (e.g. "https://myregistry.azurecr.io").')
param containerRegistryUrl string = ''

@description('Require a customer-provided storage account for the web app (used with Managed Instance).')
param storageAccountRequired bool = false

// --- Resource Group ---

@description('Name for the spoke resource group. The module creates this RG automatically — do not pass an existing resource ID.')
param resourceGroupName string = 'rg-${workloadName}-${environmentName}'

// ======================== //
// Module Deployment        //
// ======================== //

// Create the spoke resource group using the AVM resource module.
// The pattern module also references this RG name internally (idempotent).
module spokeResourceGroup 'br/public:avm/res/resources/resource-group:0.4.0' = {
  name: 'rg-${uniqueString(deployment().name, resourceGroupName)}'
  params: {
    name: resourceGroupName
    location: location
    tags: tags
    enableTelemetry: false
  }
}

// Deploy the entire App Service Landing Zone spoke via the AVM pattern module.
// This single module creates: VNet with subnets, NSGs, route tables, App
// Service Plan, Web App, Key Vault, Application Insights, Front Door with WAF,
// private endpoints, private DNS zones, and managed identities — all inside the
// resource group created above.
module hostingEnvironment 'br/public:avm/ptn/app-service-lza/hosting-environment:0.2.0' = {
  name: 'hosting-environment-${uniqueString(deployment().name)}'
  dependsOn: [spokeResourceGroup]
  params: {
    workloadName: workloadName
    location: location
    environmentName: environmentName
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    tags: tags
    deployAseV3: deployAseV3

    // Spoke network — connect to existing hub when provided
    spokeNetworkConfig: {
      resourceGroupName: resourceGroupName
      vnetAddressSpace: spokeVnetAddressSpace
      appSvcSubnetAddressSpace: spokeAppSvcSubnetAddressSpace
      privateEndpointSubnetAddressSpace: spokePrivateEndpointSubnetAddressSpace

      // Hub integration — peering + egress lockdown are activated only when
      // the hub VNet resource ID is supplied (e.g. from ALZ IaC Accelerator).
      hubVnetResourceId: !empty(hubVnetResourceId) ? hubVnetResourceId : null
      firewallInternalIp: !empty(firewallInternalIp) ? firewallInternalIp : null
      enableEgressLockdown: !empty(firewallInternalIp)

      // Front Door is the default ingress option — no App Gateway subnet needed
      ingressOption: 'frontDoor'
    }

    // App Service Plan
    servicePlanConfig: {
      sku: appServicePlanSku
      zoneRedundant: appServicePlanZoneRedundant
      kind: appServicePlanOs
      isCustomMode: appServicePlanCustomMode ? true : null
    }

    // Web App — secure defaults: HTTPS-only, basic auth disabled, TLS 1.2+
    appServiceConfig: {
      kind: appServiceKind
      httpsOnly: true
      disableBasicPublishingCredentials: true
      storageAccountRequired: storageAccountRequired
      siteConfig: {
        alwaysOn: true
        ftpsState: 'Disabled'
        minTlsVersion: '1.2'
        healthCheckPath: '/healthz'
        http20Enabled: true
      }
      container: !empty(containerImageName) ? {
        imageName: containerImageName
        registryUrl: !empty(containerRegistryUrl) ? containerRegistryUrl : null
      } : null
    }

    // Key Vault — RBAC authorization, purge protection, private access only
    keyVaultConfig: {
      enableRbacAuthorization: true
      enablePurgeProtection: true
      publicNetworkAccess: 'Disabled'
    }

    // Application Insights — private ingestion, Entra-only auth
    appInsightsConfig: {
      publicNetworkAccessForIngestion: 'Disabled'
      publicNetworkAccessForQuery: 'Disabled'
      disableLocalAuth: true
      retentionInDays: 90
    }

    // Front Door — Premium with default WAF rule that blocks unsafe HTTP methods
    frontDoorConfig: {
      enableDefaultWafMethodBlock: true
    }
  }
}

// ======================== //
// Outputs                  //
// ======================== //

@description('Name of the spoke resource group.')
output spokeResourceGroupName string = spokeResourceGroup.outputs.name

@description('Resource ID of the spoke resource group.')
output spokeResourceGroupResourceId string = spokeResourceGroup.outputs.resourceId

@description('Resource ID of the spoke VNet.')
output spokeVNetResourceId string = hostingEnvironment.outputs.spokeVNetResourceId

@description('Name of the deployed Web App.')
output webAppName string = hostingEnvironment.outputs.webAppName

@description('Default hostname of the Web App.')
output webAppHostName string = hostingEnvironment.outputs.webAppHostName

@description('Resource ID of the Key Vault.')
output keyVaultResourceId string = hostingEnvironment.outputs.keyVaultResourceId

@description('Resource ID of the App Service Plan.')
output appServicePlanResourceId string = hostingEnvironment.outputs.appServicePlanResourceId
