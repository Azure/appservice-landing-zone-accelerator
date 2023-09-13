// OpenAI Bicep Module 
@description('Required. Name of the OpenAI Account. Must be globally unique.')
@maxLength(24)
param accountName string

@description('Required. Name of the OpenAI Account. Must be globally unique.')
@maxLength(24)
param deploymentName string

@description('Optional. Location for all resources.')
param location string

@description('SKU for OpenAI Account. Default is F0. See https://docs.microsoft.com/en-us/azure/cognitive-services/openapi-reference/v20210630-preview/accounts/createaccount#skus for more details.')
param skuName string = 'F0'

@description('Optional. Custom subdomain name for the account. Must be a valid domain name.')
param customSubDomainName string = ''

@description('Optional. Enable dynamic throttling for the account. Default is false.')
param dynamicThrottlingEnabled bool = false

@description('Optional. List of allowed FQDNs for the account. Must be a valid domain name.')
param allowedFqdnList array = []

@description('Optional. Disable local authentication for the account. Default is false.')
param disableLocalAuth bool = false

@description('Optional. Restrict outbound network access for the account. Default is false.')
param restrictOutboundNetworkAccess bool = false

@description('Optional. Public network access for the account. Default is Enabled.')
param publicNetworkAccess string = 'Enabled'

@description('Optional. Name of the RAI policy to be used for the account. Default is Default.')
param raiPolicyName string = 'Default'

@description('Optional. Format of the model. Default is en.')
param modelFormat string = 'en'

@description('Optional. Version of the model. Default is latest.')
param modelVersion string = ''

@description('Optional. Name of the model. Default is latest.')
param modelName string = ''

@description('Optional. Name of the deployment SKU. Default is S0.')
param deploymentSkuName string = 'S0'

@description('Optional. Scale type of the deployment. Default is Standard.')
param deploymentScaleType string = 'Standard'

@description('Optional. IP rules for the account. Default is [].')
param ipRules array = []

@description('Optional. Virtual network rules for the account. Default is [].')
param virtualNetworkRules array = []

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param tags object = {}

resource openAIAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: accountName
  location: location
  tags: tags
  kind: 'TextAnalytics'
  sku: {
    name: skuName
  }
  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    customSubDomainName: customSubDomainName
    dynamicThrottlingEnabled: dynamicThrottlingEnabled
    allowedFqdnList: allowedFqdnList
    disableLocalAuth: disableLocalAuth
    restrictOutboundNetworkAccess: restrictOutboundNetworkAccess
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: 'Allow'
      ipRules: ipRules
      virtualNetworkRules: virtualNetworkRules
    }
    
  }
}

resource openAIDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: deploymentName
  parent: openAIAccount 
  sku: {
    name: deploymentSkuName
  }
  properties: {
    raiPolicyName: raiPolicyName
    model: {
      format: modelFormat
      name: modelName
      version: modelVersion
    }
    scaleSettings: {
      scaleType: deploymentScaleType
    }
  }
}

output openAIAccountEndpoint string = openAIAccount.properties.endpoint

output openAIAccountPrimaryKey string = openAIAccount.properties.endpoints.primaryKey

output openAIAccountSecondaryKey string = openAIAccount.properties.endpoints.secondaryKey

output openAiPrimaryKey string = openAIAccount.properties.customSubDomainName

