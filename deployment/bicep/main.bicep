targetScope='subscription'

// Parameters
@description('A short name for the workload being deployed')
param workloadName string

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

@description('The user name to be used as the Administrator for all VMs created by this deployment')
param vmUsername string

@description('The password for the Administrator user for all VMs created by this deployment')
param vmPassword string

@description('The CI/CD platform to be used, and for which an agent will be configured for the ASE deployment. Specify \'none\' if no agent needed')
@allowed([
  'github'
  'azuredevops'
  'none'
])
param CICDAgentType string

@description('The Azure DevOps or GitHub account name to be used when configuring the CI/CD agent, in the format https://dev.azure.com/ORGNAME OR github.com/ORGUSERNAME OR none')
param accountName string

@description('The Azure DevOps or GitHub personal access token (PAT) used to setup the CI/CD agent')
@secure()
param personalAccessToken string

// Variables
var location = deployment().location
var resourceSuffix = '${workloadName}-${environment}-${location}-001'
var networkingResourceGroupName = 'rg-networking-${resourceSuffix}'
var sharedResourceGroupName = 'rg-shared-${resourceSuffix}'
var aseResourceGroupName = 'rg-ase-${resourceSuffix}'

// Create resource groups
resource networkingResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: networkingResourceGroupName
  location: location
}

resource aseResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: aseResourceGroupName
  location: location
}

resource sharedResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: sharedResourceGroupName
  location: location
}

// Create networking resources
module networking 'networking.bicep' = {
  name: 'networkingresources'
  scope: resourceGroup(networkingResourceGroup.name)
  params: {
    location: location
    resourceSuffix: resourceSuffix
    createCICDAgentSubnet: ((CICDAgentType == 'none') ? false : true)
  }
}

// Get networking resource outputs
var jumpboxSubnetId = networking.outputs.jumpBoxSubnetId
var CICDAgentSubnetId = networking.outputs.CICDAgentSubnetId

// Create shared resources
module shared './shared/shared.bicep' = {  
  dependsOn: [
    networking
  ]
  name: 'sharedresources'
  scope: resourceGroup(sharedResourceGroup.name)
  params: {
    accountName: accountName
    CICDAgentSubnetId: CICDAgentSubnetId
    CICDAgentType: CICDAgentType
    environment: environment
    jumpboxSubnetId: jumpboxSubnetId
    location: location
    personalAccessToken: personalAccessToken
    resourceGroupName: sharedResourceGroup.name
    resourceSuffix: resourceSuffix
    vmPassword: vmPassword
    vmUsername: vmUsername
  }
}

// Create ASE resources
module ase 'ase.bicep' = {
  dependsOn: [
    networking
    shared
  ]
  scope: resourceGroup(aseResourceGroup.name)
  name: 'aseresources'
  params: {
    vnetId: networking.outputs.spokeVNetId
    aseSubnetId: networking.outputs.aseSubnetId
    aseSubnetName: networking.outputs.aseSubnetName
    location: location
    resourceSuffix: resourceSuffix
  }
}
