@maxLength(24)
@description('Conditional. The name of the parent Storage Account. Required if the template is used in a standalone deployment.')
param storageAccountName string

@description('Optional. The name of the table service.')
param name string = 'default'

@description('Optional. tables to create.')
param tables array = []

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName
}

resource tableServices 'Microsoft.Storage/storageAccounts/tableServices@2021-04-01' = {
  name: name
  parent: storageAccount
  properties: {}
}

module tableServices_tables 'storage.tablesvc.tables.bicep' = [for (tableName, index) in tables: {
  name: '${deployment().name}-Table-${index}'
  params: {
    storageAccountName: storageAccount.name
    tableServicesName: tableServices.name
    name: tableName
  }
}]

@description('The name of the deployed table service.')
output name string = tableServices.name

@description('The resource ID of the deployed table service.')
output resourceId string = tableServices.id

@description('The resource group of the deployed table service.')
output resourceGroupName string = resourceGroup().name
