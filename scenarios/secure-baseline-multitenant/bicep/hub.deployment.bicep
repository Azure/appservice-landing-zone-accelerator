targetScope = 'resourceGroup'

param naming object
param location string = resourceGroup().location
param tags object

var resourceNames = {
  storageAccount: naming.storageAccount.nameUnique
}



module storageHub '../../shared/bicep/storage/storage.bicep' = {
  name: 'storageHubDeployment'
  params: {    
    location: location
    name: '${resourceNames.storageAccount}hub'
    tags: tags
  }
}
