targetScope='resourceGroup'
param location string
param sharedResourceGroupResources object

param jumpboxSubnetId string
param agentSubnetId string
param vmazdevopsUsername string
param vmazdevopsPassword string
param azureDevOpsAccount string


param personalAccessToken string
param resourceGroupName string


//param environment string
//param namePrefix string = 'not set'


module appInsights './azmon.bicep' = {
  name: 'azmon'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    sharedResourceGroupResources : sharedResourceGroupResources

  }
}
output appInsightsConnectionString string = appInsights.outputs.appInsightsConnectionString


module vm_devopswinvm './createvmwindows.bicep' = {
  name: 'azdevopsvm'
  scope: resourceGroup(resourceGroupName)
  params: {
    subnetId: agentSubnetId
    username: vmazdevopsUsername
    password: vmazdevopsPassword
    vmName: 'azdevops-${sharedResourceGroupResources.vmSuffix}'
    azureDevOpsAccount: azureDevOpsAccount
    personalAccessToken: personalAccessToken
    deployAgent: true
  }
}
 
module vm_jumpboxwinvm './createvmwindows.bicep' = {
  name: 'jumpboxwinvm'
  scope: resourceGroup(resourceGroupName)
  params: {
    subnetId: jumpboxSubnetId
    username: vmazdevopsUsername
    password: vmazdevopsPassword
    vmName: 'jumpbox-${sharedResourceGroupResources.vmSuffix}'
  }
}

resource key_vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: sharedResourceGroupResources.keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }    
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
}

output devopsAgentvmName string = vm_devopswinvm.name
output jumpBoxvmName string = vm_jumpboxwinvm.name
