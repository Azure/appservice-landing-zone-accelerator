targetScope = 'subscription'

// ================ //
// Parameters       //
// ================ //

@maxLength(10)
@description('suffix that will be used to name the resources in a pattern like <resourceAbbreviation>-<applicationName>')
param applicationName string

@description('Azure region where the resources will be deployed in')
param location string

@description('Required. The name of the environment (e.g. "dev", "test", "prod", "preprod", "staging", "uat", "dr", "qa"). Up to 8 characters long.')
@maxLength(8)
param environment string

@description('CIDR of the HUB vnet i.e. 192.168.0.0/24')
param hubVnetAddressSpace string

@description('CIDR of the subnet hosting the azure Firewall')
param subnetHubFirewallAddressSpace string

@description('CIDR of the subnet hosting the Bastion Service')
param subnetHubBastionddressSpace string

@description('CIDR of the SPOKE vnet i.e. 192.168.0.0/24')
param spokeVnetAddressSpace string

@description('CIDR of the subnet that will hold the app services plan')
param subnetSpokeAppSvcAddressSpace string

@description('CIDR of the subnet that will hold devOps agents etc ')
param subnetSpokeDevOpsAddressSpace string

@description('CIDR of the subnet that will hold the private endpoints of the supporting services')
param subnetSpokePrivateEndpointAddressSpace string

@description('Optional. A numeric suffix (e.g. "001") to be appended on the naming generated for the resources. Defaults to empty.')
param numericSuffix string = ''

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param resourceTags object = {}

@description('If empty, then a new hub will be created. If given, no new hub will be created and we create the  peering between spoke and and existing hub vnet')
param vnetHubResourceId string

@description('Internal IP of the Azure firewall deployed in Hub. Used for creating UDR to route all vnet egress traffic through Firewall. If empty no UDR')
param firewallInternalIp string

@description('Telemetry is by default enabled. The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services.')
param enableTelemetry bool = true

@description('Defines the name, tier, size, family and capacity of the App Service Plan. Plans ending to _AZ, are deplying at least three instances in three Availability Zones. EP* is only for functions')
@allowed([ 'B1', 'B2', 'B3', 'S1', 'S2', 'S3', 'P1V3', 'P2V3', 'P3V3', 'P1V3_AZ', 'P2V3_AZ', 'P3V3_AZ' ])
param webAppPlanSku string

@description('Kind of server OS of the App Service Plan')
param webAppBaseOs string

@description('mandatory, the username of the admin user')
param adminUsername string

@description('mandatory, the password of the admin user')
@secure()
param adminPassword string

@description('Conditional. The Azure Active Directory (AAD) administrator authentication. Required if no `administratorLogin` & `administratorLoginPassword` is provided.')
param sqlServerAdministrators object = {}


// ================ //
// Variables        //
// ================ //

var tags = union({
  applicationName: applicationName
  environment: environment
}, resourceTags)

var resourceSuffix = '${applicationName}-${environment}-${location}'
var hubResourceGroupName = 'rg-hub-${resourceSuffix}'
var spokeResourceGroupName = 'rg-spoke-${resourceSuffix}'

var defaultSuffixes = [
  applicationName
  environment
  '**location**'
]
var namingSuffixes = empty(numericSuffix) ? defaultSuffixes : concat(defaultSuffixes, [
  numericSuffix
])

var administrators = empty (sqlServerAdministrators) ? {} : union ({
                                                                    administratorType: 'ActiveDirectory'
                                                                    principalType: 'Group'
                                                                    azureADOnlyAuthentication: true //TODO: not sure this should be default
                                                                  }, sqlServerAdministrators)

// var vnetHubResourceIdSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : split(hubVnet.id, '/')

// ================ //
// Resources        //
// ================ //

module naming '../../shared/bicep/naming.module.bicep' = {
  scope: resourceGroup(spokeResourceGroup.name)
  name: 'namingModule-Deployment'
  params: {
    location: location
    suffix: namingSuffixes
    uniqueLength: 6
  }
}

resource hubResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = if ( empty(vnetHubResourceId) ) {
  name: hubResourceGroupName
  location: location
  tags: tags
}

resource spokeResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: spokeResourceGroupName
  location: location
  tags: tags

}

module hub 'deploy.hub.bicep' =  if ( empty(vnetHubResourceId) ) {
  scope: resourceGroup(hubResourceGroup.name)
  name: take('hub-${deployment().name}-deployment', 64)
  params: {
    naming: naming.outputs.names
    location: location
    hubVnetAddressSpace: hubVnetAddressSpace
    tags: tags
    subnetHubBastionddressSpace: subnetHubBastionddressSpace
    subnetHubFirewallAddressSpace: subnetHubFirewallAddressSpace
    spokeVnetAddressSpace: spokeVnetAddressSpace
    subnetSpokeDevOpsAddressSpace: subnetSpokeDevOpsAddressSpace
  }
}

// resource hubVnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
//   scope: resourceGroup(hubResourceGroup.name)
//   name: hub.outputs.vnetHubName
// }

module spoke 'deploy.spoke.bicep' = {
  scope: resourceGroup(spokeResourceGroup.name)
  name: take('spoke-${deployment().name}-deployment', 64)
  params: {
    naming: naming.outputs.names
    location: location
    tags: tags
    firewallInternalIp: empty(vnetHubResourceId) ? hub.outputs.firewallPrivateIp : firewallInternalIp
    spokeVnetAddressSpace: spokeVnetAddressSpace
    subnetSpokeAppSvcAddressSpace: subnetSpokeAppSvcAddressSpace
    subnetSpokeDevOpsAddressSpace: subnetSpokeDevOpsAddressSpace
    subnetSpokePrivateEndpointAddressSpace: subnetSpokePrivateEndpointAddressSpace
    vnetHubResourceId: empty(vnetHubResourceId) ? hub.outputs.vnetHubId : vnetHubResourceId
    webAppBaseOs: webAppBaseOs
    adminPassword: adminPassword
    adminUsername: adminUsername
    sqlServerAdministrators: administrators   
    webAppPlanSku: webAppPlanSku 
  }
}

// once the spoke is ready we need to peer either to the newly created hub vnet, or to an existing Hub vnet
module peerings 'modules/peerings.deployment.bicep' = {
  scope: resourceGroup(spokeResourceGroup.name)
  name: take('peerings-${deployment().name}-deployment', 64)
  params: {
    rgSpokeName: spokeResourceGroup.name
    spokeName: spoke.outputs.vnetSpokeName
    vnetHubResourceId:  !empty(vnetHubResourceId) ? vnetHubResourceId :  hub.outputs.vnetHubId //hubVnet.id
  }
}

//  Telemetry Deployment
@description('Enable usage and telemetry feedback to Microsoft.')
var telemetryId = 'cf7e9f0a-f872-49db-b72f-f2e318189a6d-${location}-msb'
resource telemetrydeployment 'Microsoft.Resources/deployments@2021-04-01' = if (enableTelemetry) {
  name: telemetryId
  location: location
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#'
      contentVersion: '1.0.0.0'
      resources: {}
    }
  }
}
