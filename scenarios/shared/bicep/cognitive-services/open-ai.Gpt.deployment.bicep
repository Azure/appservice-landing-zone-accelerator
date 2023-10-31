// OpenAI Bicep Module 
@description('Required. Name of the existing OpenAI Account') 
@maxLength(64)
param openAiName string

@description('Required. Deployment Name can have only letters and numbers, no spaces. Hyphens ("-") and underscores ("_") may be used, except as ending characters.')
@minLength(2)
@maxLength(64)
param deploymentName string

@description('The model name to be deployed. The model name can be found in the OpenAI portal.')
param modelName string = 'gpt-35-turbo'

@description('The model version to be deployed. At the time of writing this is the latest version is eastus2.')
param modelVersion string = '0613'

resource openAi 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: openAiName
}

resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: deploymentName
  parent: openAi 
  sku: {
    name: 'Standard'
    capacity: 1
  }
  properties: {
    raiPolicyName: 'Microsoft.Default'
    model: {
      format: 'OpenAI'
      name: modelName
      version: modelVersion
    }
  }
}
