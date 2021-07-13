targetScope='resourceGroup'
param location string
param sharedResourceGroupResources object

param subnetId string
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
    subnetId: subnetId
    username: vmazdevopsUsername
    password: vmazdevopsPassword
    vmName: 'azdevops-${sharedResourceGroupResources.vmSuffix}'
    azureDevOpsAccount: azureDevOpsAccount
    personalAccessToken: personalAccessToken
    deployAgent: false
  }
}
 
module vm_jumpboxwinvm './createvmwindows.bicep' = {
  name: 'jumpboxwinvm'
  scope: resourceGroup(resourceGroupName)
  params: {
    subnetId: subnetId
    username: vmazdevopsUsername
    password: vmazdevopsPassword
    vmName: 'jumpbox-${sharedResourceGroupResources.vmSuffix}'
  }
}

output devopsAgentvmName string = vm_devopswinvm.name
output jumpBoxvmName string = vm_jumpboxwinvm.name
