targetScope='resourceGroup'
// Parameters
@description('Azure location to which the resources are to be deployed')
param location string

@description('Required. Application Insights instance resource name.')
param name string

@description('Required. Log Analytics workspace instance resource name.')
param logAnalyticsWorkspaceName string

@description('Optional. Tags to be added on the resources created')
param tags object = {}

// Resources
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
  tags: tags
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
  tags: tags
}

// Outputs
output appInsightsConnectionString string = appInsights.properties.ConnectionString
