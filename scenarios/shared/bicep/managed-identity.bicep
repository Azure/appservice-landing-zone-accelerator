@description('Required. The name of the user assigned managed Identity. 3-128, can contain "-" and "_"')
@minLength(3)
@maxLength(128)
param name string

@description('Optional. Location for all resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object = {}

resource muai 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: name    //3-128, can contain '-' and '_'.
  location: location
  tags: tags
}

@description('The name of the managedIDentity.')
output name string = muai.name

@description('The id of the managedIDentity.')
output id string = muai.id

@description('The type of the managedIDentity.')
output type string = muai.type

@description('The ServicePrincipalId of the managedIDentity.')
output principalId string = muai.properties.principalId

@description('The TenantId of the managedIDentity.')
output tenantId string = muai.properties.tenantId

@description('The clientId of the managedIDentity.')
output clientId string = muai.properties.clientId
