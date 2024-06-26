// ------------------
//    PARAMETERS
// ------------------

@description('Required. Name of the AFD profile.')
param afdName string

@description('Name of the endpoint under the profile which is unique globally.')
param endpointName string 

@allowed([
  'Enabled'
  'Disabled'
])
@description('AFD Endpoint State')
param endpointEnabled string = 'Enabled'

@description('Optional. Endpoint tags.')
param tags object = {}

@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
@description('Required. The pricing tier (defines a CDN provider, feature list and rate) of the CDN profile.')
param skuName string

@description('The name of the Origin Group')
param originGroupName string 

@description('Origin List')
param origins array 

@description('Optional, default value false. Set true if you need to cache content at the AFD level')
param enableCaching bool = false

@description('Name of the WAF policy to create.')
@maxLength(128)
param wafPolicyName string

@allowed([
  'Block'
  'Log'
  'Redirect'
])
param wafRuleSetAction string = 'Log'

@description('optional, default value Enabled. ')
@allowed([
  'Enabled'
  'Disabled'
])
param wafPolicyState string = 'Enabled'

@description('optional, default value Prevention. ')
@allowed([
  'Detection'
  'Prevention'
])
param wafPolicyMode string = 'Prevention'

@description('if no diagnostic serttings are required, provide an empty string. Resource ID of log analytics workspace.')
param diagnosticWorkspaceId string

@description('Optional. The name of logs that will be streamed. "allLogs" includes all possible logs for the resource.')
@allowed([
  'allLogs'
  'FrontDoorAccessLog'
  'FrontDoorWebApplicationFirewallLog'
  'FrontDoorHealthProbeLog'
])
param diagnosticLogCategoriesToEnable array = [
  'allLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${afdName}-diagnosticSettings'

// Create an Array of all Endpoint which includes customDomain Id and afdEndpoint Id
// This array is needed to be attached to Microsoft.Cdn/profiles/securitypolicies
// var customDomainIds = [for (domain, index) in customDomains: {id: custom_domains[index].id}]
// var afdEndpointIds = [{id: endpoint.id}]
// var endPointIdsForWaf = union(customDomainIds, afdEndpointIds)
// var endPointIdsForWaf = [{id: profile.outputs}]

// ------------------
//    VARIABLES
// ------------------

@description('Default Content to compress')
var contentTypeCompressionList = [
  'application/eot'
  'application/font'
  'application/font-sfnt'
  'application/javascript'
  'application/json'
  'application/opentype'
  'application/otf'
  'application/pkcs7-mime'
  'application/truetype'
  'application/ttf'
  'application/vnd.ms-fontobject'
  'application/xhtml+xml'
  'application/xml'
  'application/xml+rss'
  'application/x-font-opentype'
  'application/x-font-truetype'
  'application/x-font-ttf'
  'application/x-httpd-cgi'
  'application/x-javascript'
  'application/x-mpegurl'
  'application/x-opentype'
  'application/x-otf'
  'application/x-perl'
  'application/x-ttf'
  'font/eot'
  'font/ttf'
  'font/otf'
  'font/opentype'
  'image/svg+xml'
  'text/css'
  'text/csv'
  'text/html'
  'text/javascript'
  'text/js'
  'text/plain'
  'text/richtext'
  'text/tab-separated-values'
  'text/xml'
  'text/x-script'
  'text/x-component'
  'text/x-java-source'
]

var diagnosticsLogsSpecified = [for category in filter(diagnosticLogCategoriesToEnable, item => item != 'allLogs'): {
  category: category
  enabled: true
}]

var diagnosticsLogs = contains(diagnosticLogCategoriesToEnable, 'allLogs') ? [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
] : diagnosticsLogsSpecified

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

// ------------------
//    RESOURCES
// ------------------

module profile 'br/public:avm/res/cdn/profile:0.3.0' = {
  name: 'afdProfileDeployment'
  params: {
    name: afdName
    location: 'Global'
    sku: skuName
    originResponseTimeoutSeconds: 120
    endpointName: endpointName
    afdEndpoints: [
      {
        name: endpointName
        enabledState: endpointEnabled
        location: 'Global'
        routes: [
          {
            name: '${originGroupName}-route'
            originGroupName: originGroupName
            patternsToMatch: [
              '/*'
            ]
            forwardingProtocol: 'HttpsOnly'
            linkToDefaultDomain: 'Enabled'
            httpsRedirect: 'Enabled'
            customDomains: []
            cacheConfiguration: !enableCaching ? null :  {
              compressionSettings: {
                isCompressionEnabled: true
                contentTypesToCompress: contentTypeCompressionList
              }
              queryStringCachingBehavior: 'UseQueryString'
            }
            supportedProtocols: [
              'Https'
              'Http'
            ]
            enabledState: 'Enabled'
          }
        ]
        tags: tags
      }
    ]
    originGroups: [
      {
        loadBalancingSettings: {
          additionalLatencyInMilliseconds: 50
          sampleSize: 4
          successfulSamplesRequired: 3
        }
        name: originGroupName
        sessionAffinityState: 'Disabled'
        trafficRestorationTimeToHealedOrNewEndpointsInMinutes: 10
        origins: [for (origin, index) in origins: {
            hostName: origin.hostname
            httpPort: 80
            httpsPort: 443
            originHostHeader: origin.hostname
            priority: 1
            weight: 1000
            enabledState: origin.enabledState ? 'Enabled' : 'Disabled'
            enforceCertificateNameCheck: true
            sharedPrivateLinkResource: empty(origin.privateLinkOrigin) ? null : {
              privateLink: {
                id: origin.privateLinkOrigin.privateEndpointResourceId
              }
              groupId: (origin.privateLinkOrigin.privateLinkResourceType != '') ? origin.privateLinkOrigin.privateLinkResourceType : null
              privateLinkLocation: origin.privateLinkOrigin.privateEndpointLocation
              requestMessage: 'Please approve this connection.'
          }
        }]
        healthProbeSettings: {
          probeIntervalInSeconds: 100
          probePath: '/'
          probeProtocol: 'Https'
          probeRequestType: 'GET'
        }
      }
    ]
    tags: tags
  }
}

resource frontDoorExisting 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: afdName
}

resource endpointExisting 'Microsoft.Cdn/profiles/endpoints@2023-05-01' existing = {
  name: endpointName
  parent: frontDoorExisting
}

resource afdWafSecurityPolicy 'Microsoft.Cdn/profiles/securitypolicies@2022-11-01-preview' =  {
  parent: frontDoorExisting
  name: 'afdWafSecurityPolicy'
  properties: {
    parameters: {
      wafPolicy: {
        id:  waf.outputs.resourceId
      }
      associations: [
        {
          domains: [{id: endpointExisting.id}]
          patternsToMatch: [
            '/*'
          ]
        }
      ]
      type: 'WebApplicationFirewall'
    }
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ( !empty(diagnosticWorkspaceId)) {
  name: diagnosticSettingsName
  properties: {
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
  }
  scope: frontDoorExisting
}

module waf 'br/public:avm/res/network/front-door-web-application-firewall-policy:0.1.1' =  {
  name: 'wafDeployment'
  params: {
    name: wafPolicyName
    location: 'Global'
    sku: skuName
    policySettings: {
      enabledState: wafPolicyState
      mode: wafPolicyMode
      // customBlockResponseStatusCode: wafBlockResponseCode
      // customBlockResponseBody: base64(wafBlockResponseBody)
      requestBodyCheck: 'Enabled' 
    }
    customRules: {
      rules: [
        {
          name: 'BlockMethod'
          enabledState: 'Enabled'
          priority: 10
          ruleType: 'MatchRule'
          rateLimitDurationInMinutes: 1
          rateLimitThreshold: 100
          matchConditions: [
            {
              matchVariable: 'RequestMethod'
              operator: 'Equal'
              negateCondition: true
              matchValue: [
                'GET'
                'OPTIONS'
                'HEAD'
              ]
            }
          ]
          action: 'Block'
        }
      ]
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.1'
          ruleSetAction: wafRuleSetAction
          ruleGroupOverrides: []
        }
      ]
    }
  }
}

// ------------------
//    OUTPUTS
// ------------------

@description('The name of the CDN profile.')
output afdProfileName string = profile.name

@description('The resource ID of the CDN profile.')
output afdProfileId string = profile.outputs.resourceId

@description('Name of the endpoint.')
output endpointName string = endpointExisting.name

@description('HostName of the endpoint.')
output afdEndpointHostName string = endpointExisting.properties.hostName

@description('The resource group where the CDN profile is deployed.')
output resourceGroupName string = resourceGroup().name

@description('The type of the CDN profile.')
output profileType string = profile.outputs.profileType

