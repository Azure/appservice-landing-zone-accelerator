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

@description('Optional. A numeric suffix (e.g. "001") to be appended on the naming generated for the resources. Defaults to empty.')
param numericSuffix string = ''

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param resourceTags object = {}

@description('Telemetry is by default enabled. The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services.')
param enableTelemetry bool = true


// ================ //
// Variables        //
// ================ //

var tags = union({
  applicationName: applicationName
  environment: environment
}, resourceTags)

var resourceSuffix = '${applicationName}-${environment}-${location}'
//TODO: Change name of hubResourceGroupName (tt 20230129)
var hubResourceGroupName = 'rg-hub-test'
var spokeResourceGroupName = 'rg-${resourceSuffix}'

var defaultSuffixes = [
  applicationName
  environment
  '**location**'
]
var namingSuffixes = empty(numericSuffix) ? defaultSuffixes : concat(defaultSuffixes, [
  numericSuffix
])


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
resource hubResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: hubResourceGroupName
  location: location
  tags: tags
}

resource spokeResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: spokeResourceGroupName
  location: location
  tags: tags
}

//TODO: Needs to be optional (tt20230212)
module hub 'hub.deployment.bicep' = {
  scope: resourceGroup(hubResourceGroup.name)
  name: 'hubDeployment'
  params: {
    naming: naming.outputs.names
    location: location
    tags: tags
  }
}

module spoke 'spoke.deployment.bicep' = {
  scope: resourceGroup(hubResourceGroup.name)
  name: 'spokeDeployment'
  params: {
    naming: naming.outputs.names
    location: location
    tags: tags
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
