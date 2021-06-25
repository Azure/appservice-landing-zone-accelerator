targetScope='subscription'

param location string =  deployment().location

var sharedResourceGroupName = 'sharedResourceGroup'

resource sharedResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: sharedResourceGroupName
  location: location
}

module shared 'shared.bicep' = {
  name: 'shared'
  scope: resourceGroup(sharedResourceGroup.name)
  params: {
    location: location
  }
}
