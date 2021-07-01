targetScope='resourceGroup'
param location string
param sharedResourceGroupResources object

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: sharedResourceGroupResources.appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    // Flow_Type: 'Bluefield'
    // Request_Source: 'rest'
    // HockeyAppId: 'string'
    // SamplingPercentage: any('number')
    // DisableIpMasking: bool
    // ImmediatePurgeDataOn30Days: bool
    // WorkspaceResourceId: 'string'
    // publicNetworkAccessForIngestion: 'string'
    // publicNetworkAccessForQuery: 'string'
    // IngestionMode: 'string'
  }
}

output appInsightsConnectionString string = appInsights.properties.ConnectionString
