targetScope = 'resourceGroup'
// Parameters
@description('Azure location to which the resources are to be deployed')
param location string

@description('The full id string identifying the target subnet for the jumpbox VM')
param jumpboxSubnetId string

@description('The full id string identifying the target subnet for the CI/CD Agent VM')
param CICDAgentSubnetId string

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

@description('Required. The naming module for facilitating naming convention.')
param naming object

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

@description('Optional. Tags to be added on the resources created')
param tags object = {}

var resourceNames = {
  keyVault: naming.keyVault.nameUnique
  applicationInsights: naming.applicationInsights.name
  logAnalyticsWorkspace: naming.logAnalyticsWorkspace.name
  vmJumpbox: naming.windowsVirtualMachine.name
  vmDevOps: '${CICDAgentType}-${environment}'
}

// Resources
module appInsights './appInsights.bicep' = {
  name: 'appInsights-Deployment'
  params: {
    location: location
    name: resourceNames.applicationInsights
    logAnalyticsWorkspaceName: resourceNames.logAnalyticsWorkspace
    tags: tags
  }
}

module vmDevops './vmWindows.bicep' = if (CICDAgentType != 'none') {
  name: 'devopsvm-Deployment'
  params: {
    location: location
    name: resourceNames.vmDevOps
    subnetId: CICDAgentSubnetId
    username: vmUsername
    password: vmPassword    
    accountName: accountName
    personalAccessToken: personalAccessToken
    CICDAgentType: CICDAgentType
    deployAgent: true
    tags: tags
  }
}

module vmJumpbox './vmWindows.bicep' = {
  name: 'vmJumpbox-Deployment'
  params: {
    location: location
    name: resourceNames.vmJumpbox
    subnetId: jumpboxSubnetId
    username: vmUsername
    password: vmPassword
    CICDAgentType: CICDAgentType
    tags: tags
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: resourceNames.keyVault
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForTemplateDeployment: true // ARM is permitted to retrieve secrets from the key vault. 
    accessPolicies: [
      // {
      //   tenantId: 'string'
      //   objectId: 'string'
      //   applicationId: 'string'
      //   permissions: {
      //     keys: [
      //       'string'
      //     ]
      //     secrets: [
      //       'string'
      //     ]
      //     certificates: [
      //       'string'
      //     ]
      //     storage: [
      //       'string'
      //     ]
      //   }
      // }
    ]
  }

  resource vmPasswordSecret 'secrets@2019-09-01' = {
    name: 'vmPassword'
    properties: {
      attributes: {
        enabled: true
      }
      value: vmPassword
    }
  }
}

// Outputs
output appInsightsConnectionString string = appInsights.outputs.appInsightsConnectionString
output CICDAgentVmName string = vmDevops.name
output jumpBoxvmName string = vmJumpbox.name
output keyVaultName string = keyVault.name
