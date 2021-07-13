targetScope='subscription'
param workloadName string
param location string =  deployment().location
@description('The-- environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

// parameters for azure devops agent 
param vmazdevopsUsername string
param vmazdevopsPassword string
param vstsAccount string
param personalAccessToken string

// Variables
var resourceSuffix = '${workloadName}-${environment}-${location}-001'
var vmSuffix=environment
// RG Names Declaration
var sharedResourceGroupName = 'rg-shared-${resourceSuffix}'
var aseResourceGroupName = 'rg-ase-${resourceSuffix}'
// Create resources name using these objects and pass it as a params in module
var sharedResourceGroupResources = {
  'appInsightsName':'appin-${resourceSuffix}'
  'logAnalyticsWorkspaceName': 'logananalyticsws-${resourceSuffix}'
   'environmentName': environment
   'resourceSuffix' : resourceSuffix
   'vmSuffix' : vmSuffix
}



resource aseResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: aseResourceGroupName
  location: location
}



// shared resource group 


//  for testing -- need a subnet

var NetworkResourceGroupName = 'rg-network-${resourceSuffix}'

resource networkRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: NetworkResourceGroupName
  location: location
}

module vnet_generic './vnettest/vnetWithOutBastian.bicep' = {
  name: 'vnet'
  scope: resourceGroup(networkRg.name)
  params: {
    namePrefix: 'test-vnet'
  }
}

var subnetId=vnet_generic.outputs.subnetId

// end testing subnet


resource sharedRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: sharedResourceGroupName
  location: location
}


module shared './shared/shared.bicep' = {
  name: 'sharedresources'
  scope: resourceGroup(sharedRG.name)
  params: {
    location: location
    sharedResourceGroupResources : sharedResourceGroupResources
    subnetId: subnetId
    vmazdevopsPassword:vmazdevopsPassword
    vmazdevopsUsername: vmazdevopsUsername
    personalAccessToken: personalAccessToken
    vstsAccount: vstsAccount
    resourceGroupName: sharedRG.name
  }
}

module ase 'ase.bicep' = {
  dependsOn: [
    shared
  ]
  scope: resourceGroup(aseResourceGroup.name)
  name: 'aseresources'
  params: {
    location: location
    workloadName: workloadName
    environment: environment
  }
}
