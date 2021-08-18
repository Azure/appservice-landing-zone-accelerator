targetScope='resourceGroup'
param location string =resourceGroup().location
param sharedResourceGroupResources object

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
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


resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
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

