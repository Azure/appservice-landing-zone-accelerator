targetScope='subscription'
param workloadName string
var location = deployment().location
@description('The-- environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

// Variables
var resourceSuffix = '${workloadName}-${environment}-${location}-001'
// RG Names Declaration
var networkingResourceGroupName = 'rg-networking-${resourceSuffix}'
var sharedResourceGroupName = 'rg-shared-${resourceSuffix}'
var aseResourceGroupName = 'rg-ase-${resourceSuffix}'
// Create resources name using these objects and pass it as a params in module
var sharedResourceGroupResources = {
  'appInsightsName':'appin-${resourceSuffix}'
  'keyVaultName':'kv-${workloadName}-${environment}' // Must be between 3-24 alphanumeric characters 
}

resource networkingRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: networkingResourceGroupName
  location: location
}


resource sharedRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: sharedResourceGroupName
  location: location
}

resource aseResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: aseResourceGroupName
  location: location
}

module networking 'networking.bicep' = {
  name: 'networkingresources'
  scope: resourceGroup(networkingRG.name)
  params: {
    workloadName: workloadName
    environment: environment
  }
}

module shared 'shared.bicep' = {
  dependsOn: [
    networking
  ]
  name: 'sharedresources'
  scope: resourceGroup(sharedRG.name)
  params: {
    location: location
    sharedResourceGroupResources : sharedResourceGroupResources
  }
}

module ase 'ase.bicep' = {
  dependsOn: [
    networking
    shared
  ]
  scope: resourceGroup(aseResourceGroup.name)
  name: 'aseresources'
  params: {
    location: location
    workloadName: workloadName
    environment: environment
    aseSubnetName: networking.outputs.aseSubnetName
    aseSubnetId: networking.outputs.aseSubnetid
  }
}
