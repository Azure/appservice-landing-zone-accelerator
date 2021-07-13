targetScope='resourceGroup'
param location string =resourceGroup().location
param sharedResourceGroupResources object

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: sharedResourceGroupResources.logAnalyticsWorkspaceName
  location: location
  tags: {
    Environment: sharedResourceGroupResources.environmentName
   
  }
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}


resource appInsights 'microsoft.insights/components@2020-02-02-preview' = {
  name: sharedResourceGroupResources.appInsightsName
  location: location
  kind: 'string'
  tags: {
    displayName: 'AppInsight'
    Environment: sharedResourceGroupResources.environmentName
   
  }
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

output appInsightsConnectionString string = appInsights.properties.ConnectionString

