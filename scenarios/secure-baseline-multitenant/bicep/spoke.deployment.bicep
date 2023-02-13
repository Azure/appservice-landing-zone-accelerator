targetScope = 'resourceGroup'

// reference to the BICEP naming module
param naming object

@description('Azure region where the resources will be deployed in')
param location string = resourceGroup().location

param tags object

var resourceNames = {
  storageAccount: naming.storageAccount.nameUnique
}

module storageHub '../../shared/bicep/storage/storage.bicep' = {
  name: 'storageHubDeployment'
  params: {    
    location: location
    name: '${resourceNames.storageAccount}spoke'
    tags: tags
  }
}
