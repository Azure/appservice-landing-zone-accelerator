@description('Required. Name of the App Service Environment.')
@minLength(1)
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@allowed([
  ''
  'CanNotDelete'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = ''

@description('Optional. Resource tags.')
param tags object = {}

@allowed([
  'ASEv2'
  'ASEv3'
])
@description('Optional. Kind of resource.')
param kind string = 'ASEv3'

@description('Optional. Custom settings for changing the behavior of the App Service Environment.')
param clusterSettings array = [
  {
    name: 'DisableTls1.0'
    value: '1'
  }
]

@description('Optional. Enable the default custom domain suffix to use for all sites deployed on the ASE. If provided, then customDnsSuffixCertificateUrl and customDnsSuffixKeyVaultReferenceIdentity are required. Cannot be used when kind is set to ASEv2.')
param customDnsSuffix string = ''

@description('Conditional. The URL referencing the Azure Key Vault certificate secret that should be used as the default SSL/TLS certificate for sites with the custom domain suffix. Required if customDnsSuffix is not empty. Cannot be used when kind is set to ASEv2.')
param customDnsSuffixCertificateUrl string = ''

@description('Conditional. The user-assigned identity to use for resolving the key vault certificate reference. If not specified, the system-assigned ASE identity will be used if available. Required if customDnsSuffix is not empty. Cannot be used when kind is set to ASEv2.')
param customDnsSuffixKeyVaultReferenceIdentity string = ''

@description('Optional. The Dedicated Host Count. If `zoneRedundant` is false, and you want physical hardware isolation enabled, set to 2. Otherwise 0. Cannot be used when kind is set to ASEv2.')
param dedicatedHostCount int = 0

@description('Optional. DNS suffix of the App Service Environment.')
param dnsSuffix string = ''

@description('Optional. Scale factor for frontends.')
param frontEndScaleFactor int = 15

@description('Optional. Specifies which endpoints to serve internally in the Virtual Network for the App Service Environment. - None, Web, Publishing, Web,Publishing. "None" Exposes the ASE-hosted apps on an internet-accessible IP address.')
@allowed([
  'None'
  'Web'
  'Publishing'
  'Web, Publishing'
])
param internalLoadBalancingMode string = 'Web, Publishing'

@description('Optional. Number of IP SSL addresses reserved for the App Service Environment. Cannot be used when kind is set to ASEv3.')
param ipsslAddressCount int = 0

@description('Optional. Frontend VM size. Cannot be used when kind is set to ASEv3.')
@allowed([
  ''
  'Medium'
  'Large'
  'ExtraLarge'
  'Standard_D2'
  'Standard_D3'
  'Standard_D4'
  'Standard_D1_V2'
  'Standard_D2_V2'
  'Standard_D3_V2'
  'Standard_D4_V2'
])
param multiSize string = ''

@description('Optional. Property to enable and disable new private endpoint connection creation on ASE. Ignored when kind is set to ASEv2. If you wish to add a Premium AFD in front of the ASEv3, set this to true.')
param allowNewPrivateEndpointConnections bool = false

@description('Optional. Property to enable and disable FTP on ASEV3. Ignored when kind is set to ASEv2.')
param ftpEnabled bool = false

@description('Optional. Customer provided Inbound IP Address. Only able to be set on Ase create. Ignored when kind is set to ASEv2.')
param inboundIpAddressOverride string = ''

@description('Optional. Property to enable and disable Remote Debug on ASEv3. Ignored when kind is set to ASEv2.')
param remoteDebugEnabled bool = false

@description('Optional. Specify preference for when and how the planned maintenance is applied.')
@allowed([
  'Early'
  'Late'
  'Manual'
  'None'
])
param upgradePreference string = 'None'

@description('Required. ResourceId for the subnet.')
param subnetResourceId string

@description('Optional. User added IP ranges to whitelist on ASE DB. Cannot be used with \'kind\' `ASEv3`.')
param userWhitelistedIpRanges array = []

@description('Optional. Switch to make the App Service Environment zone redundant. If enabled, the minimum App Service plan instance count will be three, otherwise 1. If enabled, the `dedicatedHostCount` must be set to `-1`.')
param zoneRedundant bool = false

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''


@description('Optional. The name of logs that will be streamed. "allLogs" includes all possible logs for the resource. Set to \'\' to disable log collection.')
@allowed([
  ''
  'allLogs'
  'AppServiceEnvironmentPlatformLogs'
])
param diagnosticLogCategoriesToEnable array = [
  'allLogs'
]

@description('Optional. The name of the diagnostic setting, if deployed. If left empty, it defaults to "<resourceName>-diagnosticSettings".')
param diagnosticSettingsName string = '${name}-diagnosticSettings'

var diagnosticsLogsSpecified = [for category in filter(diagnosticLogCategoriesToEnable, item => item != 'allLogs' && item != ''): {
  category: category
  enabled: true
}]

var diagnosticsLogs = contains(diagnosticLogCategoriesToEnable, 'allLogs') ? [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
] : contains(diagnosticLogCategoriesToEnable, '') ? [] : diagnosticsLogsSpecified


resource appServiceEnvironment 'Microsoft.Web/hostingEnvironments@2022-09-01' = {
  name: name
  kind: kind
  location: location
  tags: tags
  properties: {
    clusterSettings: clusterSettings
    dedicatedHostCount: dedicatedHostCount != 0 ? dedicatedHostCount : null
    dnsSuffix: !empty(dnsSuffix) ? dnsSuffix : null
    frontEndScaleFactor: frontEndScaleFactor
    internalLoadBalancingMode: internalLoadBalancingMode
    ipsslAddressCount: ipsslAddressCount != 0 ? ipsslAddressCount : null
    multiSize: !empty(multiSize) ? any(multiSize) : null
    upgradePreference: upgradePreference
    userWhitelistedIpRanges: !empty(userWhitelistedIpRanges) ? userWhitelistedIpRanges : null
    virtualNetwork: {
      id: subnetResourceId
      subnet: last(split(subnetResourceId, '/'))
    }
    zoneRedundant: zoneRedundant
  }
}

module appServiceEnvironment_configurations_networking 'ase.networking-configuration.bicep' = if (kind == 'ASEv3') {
  name: 'AppServiceEnv-Configurations-Networking-${uniqueString(deployment().name, location)}'
  params: {
    hostingEnvironmentName: appServiceEnvironment.name
    allowNewPrivateEndpointConnections: allowNewPrivateEndpointConnections
    ftpEnabled: ftpEnabled
    inboundIpAddressOverride: inboundIpAddressOverride
    remoteDebugEnabled: remoteDebugEnabled
  }
}

module appServiceEnvironment_configurations_customDnsSuffix 'ase.custom-dns-configuration.bicep' = if (kind == 'ASEv3' && !empty(customDnsSuffix)) {
  name: 'AppServiceEnv-Configurations-CustomDnsSuffix-${uniqueString(deployment().name, location)}'
  params: {
    hostingEnvironmentName: appServiceEnvironment.name
    certificateUrl: customDnsSuffixCertificateUrl
    keyVaultReferenceIdentity: customDnsSuffixKeyVaultReferenceIdentity
    dnsSuffix: customDnsSuffix
  }
}

resource appServiceEnvironment_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock)) {
  name: '${appServiceEnvironment.name}-${lock}-lock'
  properties: {
    level: any(lock)
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: appServiceEnvironment
}

resource appServiceEnvironment_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ( !empty(diagnosticWorkspaceId) ) {
  name: !empty(diagnosticSettingsName) ? diagnosticSettingsName : '${name}-diagnosticSettings'
  properties: {
    storageAccountId: null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId:  null
    eventHubName: null
    logs: diagnosticsLogs
  }
  scope: appServiceEnvironment
}

@description('The resource ID of the App Service Environment.')
output resourceId string = appServiceEnvironment.id

@description('The resource group the App Service Environment was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The name of the App Service Environment.')
output name string = appServiceEnvironment.name

@description('The location the resource was deployed into.')
output location string = appServiceEnvironment.location
