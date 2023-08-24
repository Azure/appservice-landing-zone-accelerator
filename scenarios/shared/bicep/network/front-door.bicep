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

// @description('Custom Domain List')
// param customDomains array

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

// Create an Array of all Endpoint which includes customDomain Id and afdEndpoint Id
// This array is needed to be attached to Microsoft.Cdn/profiles/securitypolicies
// var customDomainIds = [for (domain, index) in customDomains: {id: custom_domains[index].id}]
// var afdEndpointIds = [{id: endpoint.id}]
// var endPointIdsForWaf = union(customDomainIds, afdEndpointIds)
var endPointIdsForWaf = [{id: endpoint.id}]

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

@description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${afdName}-diagnosticSettings'


resource profile 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: afdName
  location: 'Global'
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    originResponseTimeoutSeconds: 120
  }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2022-11-01-preview' = {
  parent: profile
  name: endpointName
  location: 'Global'
  properties: {
    enabledState: endpointEnabled
  }
}

// resource custom_domains 'Microsoft.Cdn/profiles/customdomains@2022-11-01-preview' = [for (customdomain, index) in customDomains: {
//   parent: profile
//   name: replace(customdomain.hostname, '.', '-')
//   properties: {
//     hostName: customdomain.hostname
//     tlsSettings: {
//       certificateType: 'ManagedCertificate'
//       minimumTlsVersion: 'TLS12'
//       }
//   }
// }]

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2022-11-01-preview' =  {
  parent: profile
  name: originGroupName
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'GET'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Disabled'
    trafficRestorationTimeToHealedOrNewEndpointsInMinutes: 10
  }
}

// var originType = {
//   name: ''  //1-50 Alphanumerics and hyphens
//   hostname: ''
//   enabledState: true
//   //null or object
//   privateLinkOrigin: {
//     privateEndpointResourceId: 'Id of the PrivateLinkService (i.e. Internal Loaf Balancer) or the Id of the Resource (i.e. App Service)'
//     privateLinkResourceType: 'empty for PrivateLinks Service - or "sites" for App Service'
//     privateEndpointLocation: 'the Closest location to the Origin'
//   }
// }
@description('For a description of the sharedPrivateLinkResource type look the above comment')
resource afdOrigins 'Microsoft.Cdn/profiles/originGroups/origins@2022-11-01-preview' = [for (origin, index) in origins: {
  parent: originGroup
  name: replace(origin.hostname, '.', '-')
  properties: {
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
  }
}]

resource originRoute 'Microsoft.Cdn/profiles/afdendpoints/routes@2021-06-01' =  {
  parent: endpoint
  name: '${originGroup.name}-route'
  properties: {
    cacheConfiguration: !enableCaching ? null :  {
      compressionSettings: {
        isCompressionEnabled: true
        contentTypesToCompress: contentTypeCompressionList
      }
      queryStringCachingBehavior: 'UseQueryString'
    }
    // customDomains: [ for (domain, cid) in customDomains: {
    //   id: custom_domains[cid].id
    // }]
    customDomains: []
    originGroup: {
      id: originGroup.id
    }
    // ruleSets: routeRuleSets
    supportedProtocols: [
      'Https'
      'Http'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
  dependsOn: [
    afdOrigins
  ]
}

resource afdWafSecurityPolicy 'Microsoft.Cdn/profiles/securitypolicies@2022-11-01-preview' =  {
  parent: profile
  name: 'afdWafSecurityPolicy'
  properties: {
    parameters: {
      wafPolicy: {
        id:  waf.id
      }
      associations: [
        {
          domains: endPointIdsForWaf
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
  scope: profile
}

resource waf 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' =  {
  name: wafPolicyName
  location: 'Global'
  sku: {
    name: skuName
  }
  properties: {
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


@description('The name of the CDN profile.')
output afdProfileName string = profile.name

@description('The resource ID of the CDN profile.')
output afdProfileId string = profile.id

@description('Name of the endpoint.')
output endpointName string = endpoint.name

@description('HostName of the endpoint.')
output afdEndpointHostName string = endpoint.properties.hostName

@description('The resource group where the CDN profile is deployed.')
output resourceGroupName string = resourceGroup().name

@description('The type of the CDN profile.')
output profileType string = profile.type


// NOTE: 
// var ruleGroupOverrides =  [
//             {
//               ruleGroupName: 'NODEJS'
//               rules: [
//                 {
//                   ruleId: '934100'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//               ]
//             }
//             {
//               ruleGroupName: 'General'
//               rules: [
//                 {
//                   ruleId: '200003'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '200002'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//               ]
//             }
//             {
//               ruleGroupName: 'PROTOCOL-ENFORCEMENT'
//               rules: [
//                 {
//                   ruleId: '920480'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920470'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920450'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920440'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920430'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920420'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920350'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920341'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920340'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920330'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920320'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920311'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920310'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920300'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920290'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920280'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920271'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920270'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920260'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920240'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920230'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920220'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920210'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920201'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920200'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920190'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920180'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920171'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920170'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920160'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920121'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920120'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '920100'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//               ]
//             }
//             {
//               ruleGroupName: 'METHOD-ENFORCEMENT'
//               rules: [
//                 {
//                   ruleId: '911100'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//               ]
//             }
//             {
//               ruleGroupName: 'JAVA'
//               rules: [
//                 {
//                   ruleId: '944250'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '944240'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '944210'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '944200'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '944130'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '944120'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '944110'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '944100'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//               ]
//             }
//             {
//               ruleGroupName: 'FIX'
//               rules: [
//                 {
//                   ruleId: '943120'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '943110'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '943100'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//               ]
//             }
//             {
//               ruleGroupName: 'SQLI'
//               rules: [
//                 {
//                   ruleId: '942510'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942500'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942480'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942470'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942450'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942440'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942430'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942410'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942400'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942390'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942380'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942370'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942361'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942360'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942350'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942340'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942330'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942320'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942310'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942300'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942290'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942280'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942270'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942260'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942250'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942240'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942230'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942220'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942210'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942200'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942190'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942180'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942170'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942160'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942150'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942140'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942120'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942110'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '942100'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//               ] 
//             }
//             {
//               ruleGroupName: 'XSS'
//               rules: [
//                 {
//                   ruleId: '941380'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941370'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941360'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941350'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941340'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941330'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941320'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941310'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941300'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941290'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941280'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941270'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941260'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941250'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941240'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941230'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941220'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941210'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941200'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941190'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941180'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941170'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941160'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941150'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941140'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941130'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941120'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941110'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941101'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '941100'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//               ] 
//             }
//             {
//               ruleGroupName: 'PHP'
//               rules: [
//                 {
//                   ruleId: '933210'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '933200'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '933180'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '933170'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '933160'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '933151'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '933150'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '933140'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '933130'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '933120'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '933110'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '933100'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//               ]
//             }
//             {
//               ruleGroupName: 'RCE'
//               rules: [
//                 {
//                   ruleId: '932180'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '932171'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '932170'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '932160'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '932150'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '932140'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '932130'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '932120'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '932115'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '932110'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '932105'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '932100'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//               ] 
//             }
//             {
//               ruleGroupName: 'RFI'
//               rules: [
//                 {
//                   ruleId: '931130'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '931120'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '931110'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '931100'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//               ]
//             }
//             {
//               ruleGroupName: 'LFI'
//               rules: [
//                 {
//                   ruleId: '930130'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '930120'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '930110'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '930100'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//               ]
//             }
//             {
//               ruleGroupName: 'PROTOCOL-ATTACK'
//               rules: [
//                 {
//                   ruleId: '921151'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '921160'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '921150'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '921140'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '921130'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '921120'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '921110'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//               ]
//             }
//             {
//               ruleGroupName: 'MS-ThreatIntel-CVEs'
//               rules: [
//                 {
//                   ruleId: '99001016'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '99001015'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '99001014'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '99001001'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//               ] 
//             }
//             {
//               ruleGroupName: 'MS-ThreatIntel-SQLI'
//               rules: [
//                 {
//                   ruleId: '99031002'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '99031001'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//               ]
//             }
//             {
//               ruleGroupName: 'MS-ThreatIntel-AppSec'
//               rules: [
//                 {
//                   ruleId: '99030002'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '99030001'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//               ]
//             }
//             {
//               ruleGroupName: 'MS-ThreatIntel-WebShells'
//               rules: [
//                 {
//                   ruleId: '99005006'
//                   enabledState: 'Disabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '99005004'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '99005003'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//                 {
//                   ruleId: '99005002'
//                   enabledState: 'Enabled'
//                   action: 'Log'
//                 }
//               ]
//             }
//           ]
