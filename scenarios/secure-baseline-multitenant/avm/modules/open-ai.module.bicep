// ------------------
//    PARAMETERS
// ------------------

@description('Required. Name of the OpenAI Account. Must be globally unique. Only alphanumeric characters and hyphens are allowed. The value must be 2-64 characters long and cannot start or end with a hyphen') 
@minLength(2)
@maxLength(64)
param name string

@description('Required. Name of the sample deployment. Deployment Name can have only letters and numbers, no spaces. Hyphens ("-") and underscores ("_") may be used, except as ending characters.')
@minLength(2)
@maxLength(64)
param deploymentName string = 'testGPT35'

@description('Optional. The location to deploy the Redis cache service.')
param location string 

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Array of custom objects describing vNet links of the DNS zone. Each object should contain vnetName, vnetId, registrationEnabled')
param virtualNetworkLinks array = []

@description('Default is empty. If empty no Private endpoint will be created for the resoure. Otherwise, the subnet where the private endpoint will be attached to')
param subnetPrivateEndpointId string = ''

@description('if empty, private dns zone will be deployed in the current RG scope')
param vnetHubResourceId string

@description('An existing Log Analytics WS Id for creating app Insights, diagnostics etc.')
param logAnalyticsWsId string

@description('Deploy (or not) a model on the openAI Account. This is used only as a sample to show how to deploy a model on the OpenAI account.')
param deployOpenAiGptModel bool = false

var vnetHubSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')
var openAiDnsZoneName = 'privatelink.openai.azure.com' 

// ------------------
//    RESOURCES
// ------------------

module openAI '../../../shared/bicep/cognitive-services/open-ai.bicep' = {
  name: 'openAI-${name}-Deployment'
  params: {
    name: name
    location: location
    tags: tags
    hasPrivateLinks: !empty(subnetPrivateEndpointId)
    diagnosticSettings: [
      {
        name: 'OpenAI-Default-Diag'        
        workspaceResourceId: logAnalyticsWsId
      }
    ]
  }
}

module gpt35TurboDeployment  '../../../shared/bicep/cognitive-services/open-ai.Gpt.deployment.bicep' = if (deployOpenAiGptModel) {
    name: 'GPT-${name}-Deployment'
    params: {
      openAiName: name
      deploymentName: deploymentName
    }
    dependsOn:[
      openAI
    ]
}

module openAiPrivateDnsZone '../../../shared/bicep/private-dns-zone.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
  // conditional scope is not working: https://github.com/Azure/bicep/issues/7367
  //scope: empty(vnetHubResourceId) ? resourceGroup() : resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4]) 
  scope: resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4])
  name: take('${replace(openAiDnsZoneName, '.', '-')}-PrivateDnsZoneDeployment', 64)
  params: {
    name: openAiDnsZoneName
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}

module peOpenAI '../../../shared/bicep/private-endpoint.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
  name: take('pe-${name}-Deployment', 64)
  params: {
    name: take('pe-${name}', 64)
    location: location
    tags: tags
    privateDnsZonesId: openAiPrivateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: openAI.outputs.resourceId
    snetId: subnetPrivateEndpointId
    subresource: 'account'
  }
}
