targetScope='subscription'

// Parameters
@description('Required. A short name for the workload being deployed')
param workloadName string

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

@description('Required. The user name to be used as the Administrator for all VMs created by this deployment')
param vmUsername string

@description('Required. The password for the Administrator user for all VMs created by this deployment')
param vmPassword string

@description('The CI/CD platform to be used, and for which an agent will be configured for the ASE deployment. Specify \'none\' if no agent needed')
@allowed([
  'github'
  'azuredevops'
  'none'
])
param CICDAgentType string

@description('Required. The Azure DevOps or GitHub account name to be used when configuring the CI/CD agent, in the format https://dev.azure.com/ORGNAME OR github.com/ORGUSERNAME OR none')
param accountName string

@description('Required. The Azure DevOps or GitHub personal access token (PAT) used to setup the CI/CD agent')
@secure()
param personalAccessToken string

@description('Optional. The tags to be assigned the created resources.')
param tags object = {}

param location string = deployment().location

// Variables

var defaultTags = union({
  app: workloadName
  env: environment
}, tags)

var resourceSuffix = '${workloadName}-${environment}-${location}'
var networkingResourceGroupName = 'rg-networking-${resourceSuffix}'
var sharedResourceGroupName = 'rg-shared-${resourceSuffix}'
var aseResourceGroupName = 'rg-ase-${resourceSuffix}'

var defaultSuffixes = [
  workloadName
  environment
  '**location**'
]
var namingSuffixes = empty(numericSuffix) ? defaultSuffixes : concat(defaultSuffixes, [ 
  numericSuffix
])

module naming 'modules/naming.module.bicep' = {
  scope: resourceGroup(aseResourceGroup.name)
  name: 'namingModule-Deployment'
  params: {
    location: location
    suffix: namingSuffixes
    uniqueLength: 6
  }
}

// Create resource groups
resource networkingResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: networkingResourceGroupName
  location: location
  tags: defaultTags
}

resource aseResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: aseResourceGroupName
  location: location
  tags: defaultTags
}

resource sharedResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: sharedResourceGroupName
  location: location
  tags: defaultTags
}

// Create networking resources
module networking 'networking.bicep' = {
  name: 'network-Deployment'
  scope: resourceGroup(networkingResourceGroup.name)
  params: {
    location: location
    resourceSuffix: resourceSuffix
    createCICDAgentSubnet: ((CICDAgentType == 'none') ? false : true)
    tags: defaultTags
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
  name: 'sharedresources-Deployment'
  scope: resourceGroup(sharedResourceGroup.name)
  params: {
    location: location
    accountName: accountName
    CICDAgentSubnetId: CICDAgentSubnetId
    CICDAgentType: CICDAgentType
    environment: environment
    jumpboxSubnetId: jumpboxSubnetId    
    personalAccessToken: personalAccessToken
    resourceSuffix: resourceSuffix
    vmPassword: vmPassword
    vmUsername: vmUsername
    tags: defaultTags
  }
}

// Create ASE resources
module ase 'ase.bicep' = {
  dependsOn: [
    networking
    shared
  ]
  scope: resourceGroup(aseResourceGroup.name)
  name: 'ase-Deployment'
  params: {
    location: location
    vnetId: networking.outputs.spokeVNetId
    aseSubnetId: networking.outputs.aseSubnetId
    aseSubnetName: networking.outputs.aseSubnetName
    resourceSuffix: resourceSuffix
    naming: naming.outputs.names
    tags: defaultTags
  }
}
