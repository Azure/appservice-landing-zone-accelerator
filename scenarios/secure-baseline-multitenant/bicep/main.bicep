targetScope = 'subscription'

// ================ //
// Parameters       //
// ================ //

@description('suffix that will be used to name the resources in a pattern like <resourceAbbreviation>-<applicationName>')
param applicationName string

@description('Azure region where the resources will be deployed in')
param location string

@description('Required. The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
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

@description('Telemetry is by default enabled. The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services.')
param enableTelemetry bool = true

@description('Kind of server OS of the App Service Plan')
param webAppBaseOS string

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
//TODO: Change name of hubResourceGroupName (tt 20230129)
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

//TODO: we need to consider if we do peering no matter waht (existing or new hub resources) - maybe rbac of end user is not enough
// var vnetHubResourceIdSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : split(hubVnet.id, '/')

// ================ //
// Resources        //
// ================ //

// TODO: Must be shared among diferrent scenarios: Change in ASE (tt20230129)
module naming '../../shared/bicep/naming.module.bicep' = {
  scope: resourceGroup(spokeResourceGroup.name)
  name: 'namingModule-Deployment'
  params: {
    location: location
    suffix: namingSuffixes
    uniqueLength: 6
  }
}

//TODO: hub must be optional to create - might already exist and we need to attach to - might be in different subscription (tt20230129)
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

module hub 'hub.deployment.bicep' =  if ( empty(vnetHubResourceId) ) {
  scope: resourceGroup(hubResourceGroup.name)
  name: 'hubDeployment'
  params: {
    naming: naming.outputs.names
    location: location
    hubVnetAddressSpace: hubVnetAddressSpace
    tags: tags
    subnetHubBastionddressSpace: subnetHubBastionddressSpace
    subnetHubFirewallAddressSpace: subnetHubFirewallAddressSpace
  }
}

// resource hubVnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
//   scope: resourceGroup(hubResourceGroup.name)
//   name: hub.outputs.vnetHubName
// }

module spoke 'spoke.deployment.bicep' = {
  scope: resourceGroup(spokeResourceGroup.name)
  name: 'spokeDeployment'
  params: {
    naming: naming.outputs.names
    location: location
    tags: tags
    spokeVnetAddressSpace: spokeVnetAddressSpace
    subnetSpokeAppSvcAddressSpace: subnetSpokeAppSvcAddressSpace
    subnetSpokeDevOpsAddressSpace: subnetSpokeDevOpsAddressSpace
    subnetSpokePrivateEndpointAddressSpace: subnetSpokePrivateEndpointAddressSpace
    vnetHubResourceId: empty(vnetHubResourceId) ? hub.outputs.vnetHubId : vnetHubResourceId
    webAppBaseOS: webAppBaseOS
    adminPassword: adminPassword
    adminUsername: adminUsername
    sqlServerAdministrators: administrators
  }
}

// once the spoke is ready we need to peer either to the newly created hub vnet, or to an existing Hub vnet
//TODO: we might need not to peer at all (because of lack of RBAC)
module peerings 'modules/peerings.deployment.bicep' = {
  scope: resourceGroup(spokeResourceGroup.name)
  name: 'peerings-deployment'
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
