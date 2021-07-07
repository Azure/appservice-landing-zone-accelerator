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

resource key_vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: sharedResourceGroupResources.keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }    
    accessPolicies: [
      // {
      //   tenantId: 'string'
      //   objectId: 'string'
      //   applicationId: 'string'
      //   permissions: {
      //     keys: [
      //       'string'
      //     ]
      //     secrets: [
      //       'string'
      //     ]
      //     certificates: [
      //       'string'
      //     ]
      //     storage: [
      //       'string'
      //     ]
      //   }
      // }
    ]
  }
}

output appInsightsConnectionString string = appInsights.properties.ConnectionString
