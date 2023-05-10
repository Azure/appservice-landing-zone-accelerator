@description('The name of the spoke vnet')
param spokeName string

@description('The name of the spoke  resource group')
param rgSpokeName string

@description('The resource if of the hub vnet')
param vnetHubResourceId string


var vnetHubResourceIdSplitTokens = split(vnetHubResourceId, '/') 

module peerSpokeToHub '../../../shared/bicep/network/peering.bicep' = {
  name: 'peerSpokeToHubDeployment'
  scope: resourceGroup(last(split(subscription().id, '/'))!, rgSpokeName)
  params: {
    localVnetName: spokeName
    remoteVnetName: vnetHubResourceIdSplitTokens[8]
    remoteRgName: vnetHubResourceIdSplitTokens[4]
    remoteSubscriptionId: vnetHubResourceIdSplitTokens[2]
  }
}

module peerHubToSpoke '../../../shared/bicep/network/peering.bicep' =   {
  name: 'peerHubToSpokeDeployment'
  scope: resourceGroup(vnetHubResourceIdSplitTokens[2], vnetHubResourceIdSplitTokens[4])
    params: {
      localVnetName: vnetHubResourceIdSplitTokens[8]
      remoteVnetName: spokeName
      remoteRgName: rgSpokeName
      remoteSubscriptionId: last(split(subscription().id, '/'))!
  }
}
