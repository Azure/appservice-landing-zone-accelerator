targetScope='subscription'
param workloadName string
var location = deployment().location
@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

// parameters for azure devops agent 
param vmUsername string
param vmPassword string
param accountName string
param personalAccessToken string

@description('The environment for which the deployment is being executed')
@allowed([
  'github'
  'azuredevops'
  'none'
])
param orgtype string
// temporary need to specify the aseLocation as "West Europe" and not as "westeurope"
param aseLocation string

// Variables
var resourceSuffix = '${workloadName}-${environment}-${location}-001'
var vmSuffix=environment
// RG Names Declaration
var networkingResourceGroupName = 'rg-networking-${resourceSuffix}'
var sharedResourceGroupName = 'rg-shared-${resourceSuffix}'
var aseResourceGroupName = 'rg-ase-${resourceSuffix}'
// Create resources name using these objects and pass it as a params in module
var sharedResourceGroupResources = {
  'appInsightsName':'appi-${resourceSuffix}'
  'logAnalyticsWorkspaceName': 'log-${resourceSuffix}'
  'environmentName': environment
  'resourceSuffix' : resourceSuffix
  'vmSuffix' : vmSuffix
  'keyVaultName':'kv-${workloadName}-${environment}' // Must be between 3-24 alphanumeric characters 
}



resource networkingRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: networkingResourceGroupName
  location: location
}




resource aseResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: aseResourceGroupName
  location: location
}




resource sharedRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: sharedResourceGroupName
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

var jumpboxSubnetId= networking.outputs.jumpBoxSubnetid
var agentSubnetId=networking.outputs.devOpsSubnetid

module shared './shared/shared.bicep' = {  dependsOn: [
    networking
  ]
  name: 'sharedresources'
  scope: resourceGroup(sharedRG.name)
  params: {
    location: location
    sharedResourceGroupResources : sharedResourceGroupResources
    jumpboxSubnetId: jumpboxSubnetId
    agentSubnetId: agentSubnetId
    vmdevopsPassword: vmPassword
    vmdevopsUsername: vmUsername
    personalAccessToken: personalAccessToken
    accountname: accountName
    orgtype: orgtype
    resourceGroupName: sharedRG.name
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
    aseLocation: aseLocation
    workloadName: workloadName
    environment: environment
    aseSubnetName: networking.outputs.aseSubnetName
    aseSubnetId: networking.outputs.aseSubnetid
  }
}
