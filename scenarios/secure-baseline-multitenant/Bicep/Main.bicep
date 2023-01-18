param cmLocation1 string = 'West Europe'
param cmLocation2 string = cmLocation1
param AppServiceName string

@secure()
param AzureSqlLoginPassword string
param HubVNetName string
param SpokeVnetName string
param SqlServerAdminAccountName string

var appConfiguration1_var = '${AppServiceName}-AppConfig'
var applicationInsights1_var = '${AppServiceName}-ApplicationInsight'
var appServiceConfigRegionalVirtualNetworkIntegration1 = 'virtualNetwork'
var bastion1_var = '${HubVNetName}-Bastion'
var cDNProfileFrontDoor1_var = '${AppServiceName}-afd'
var cDNProfileFrontDoorEndpoint1 = '${cDNProfileFrontDoor1_var}-Endpoints'
var cDNProfileFrontDoorEndpointsRoute1 = '${cDNProfileFrontDoor1_var}-route'
var cDNProfileFrontDoorOriginGroup1 = '${cDNProfileFrontDoor1_var}-AfdAsOG'
var cDNProfileFrontDoorOriginGroupOrigin1 = '${cDNProfileFrontDoor1_var}-origin'
var containerRegistry1_var = '${AppServiceName}ContainerRegistry'
var dDOSProtectionPlan1_var = '${SpokeVnetName}-DDOSProtection'
var keyVault1_var = '${AppServiceName}-KeyVault'
var networkFirewall1_var = '${HubVNetName}-FireWall'
var networkPrivateDnsZone1_var = 'privatelink.azconfig.io'
var networkPrivateDnsZone2_var = 'privatelink.vaultcore.azure.net'
var networkPrivateDnsZone3_var = 'privatelink.database.windows.net'
var networkPrivateDnsZone4_var = 'privatelink.redis.cache.windows.net'
var networkPrivateDnsZone5_var = 'privatelink.azurewebsites.net'
var networkPrivateDnsZone6_var = 'privatelink.azurecr.io'
var networkPrivateDnsZoneVirtualNetworkLink1 = 'hub'
var networkPrivateDnsZoneVirtualNetworkLink10 = 'SpokeAppService'
var networkPrivateDnsZoneVirtualNetworkLink11 = 'spoke'
var networkPrivateDnsZoneVirtualNetworkLink12 = 'hub'
var networkPrivateDnsZoneVirtualNetworkLink2 = 'spoke'
var networkPrivateDnsZoneVirtualNetworkLink3 = 'hub'
var networkPrivateDnsZoneVirtualNetworkLink4 = 'spoke'
var networkPrivateDnsZoneVirtualNetworkLink5 = 'spoke'
var networkPrivateDnsZoneVirtualNetworkLink6 = 'hub'
var networkPrivateDnsZoneVirtualNetworkLink7 = 'hub'
var networkPrivateDnsZoneVirtualNetworkLink8 = 'spoke'
var networkPrivateDnsZoneVirtualNetworkLink9 = 'HubAppService'
var networkPrivateEndpoint1_var = '${SpokeVnetName}-ACPE'
var networkPrivateEndpoint2_var = '${SpokeVnetName}-CrPE'
var networkPrivateEndpoint3_var = '${SpokeVnetName}-SqlPE'
var networkPrivateEndpoint4_var = '${SpokeVnetName}-KVPE'
var networkPrivateEndpoint5_var = '${SpokeVnetName}-AppSVC'
var networkSecurityGroup1_var = '${subnet1}-NSG'
var networkSecurityGroup2_var = '${subnet2}-NSG'
var networkSecurityGroup3_var = '${subnet3}-NSG'
var networkSecurityGroup4_var = '${subnet4}-NSG'
var networkSecurityGroup5_var = '${subnet5}-NSG'
var networkVirtualNetworkVirtualNetworkPeering1 = 'HubPeering'
var networkVirtualNetworkVirtualNetworkPeering2 = 'Spoke'
var operationalInsightsWorkspace1_var = '${AppServiceName}-LogAnalytics'
var publicIpAddress1_var = '${subnet4}-PIP'
var publicIpAddress2_var = 'AzFirewallpop'
var resourceGroup1 = '${AppServiceName}-ResourceGroup'
var sQLServer1_var = '${AppServiceName}-SQL'
var subnet1 = '${SpokeVnetName}-PrivateLinkSubnet'
var subnet2 = '${SpokeVnetName}-AppServiceIntegrationVnet'
var subnet3 = '${SpokeVnetName}-AFDSubnet'
var subnet4 = 'AzureBastionSubnet'
var subnet5 = '${SpokeVnetName}-VmssSubnet'
var subnet6 = 'AzureFirewallSubnet'
var webServerfarm1_var = '${AppServiceName}-AppServicePlan'

resource keyVault1 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVault1_var
  location: cmLocation2
  properties: {
    accessPolicies: []
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
  }
}

resource appConfiguration1 'Microsoft.AppConfiguration/configurationStores@2019-10-01' = {
  name: appConfiguration1_var
  location: cmLocation2
  properties: {
  }
  sku: {
    name: 'Standard'
  }
}

resource operationalInsightsWorkspace1 'Microsoft.OperationalInsights/workspaces@2015-11-01-preview' = {
  name: operationalInsightsWorkspace1_var
  location: cmLocation2
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource applicationInsights1 'Microsoft.Insights/components@2015-05-01' = {
  name: applicationInsights1_var
  location: cmLocation2
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

resource dDOSProtectionPlan1 'Microsoft.Network/ddosProtectionPlans@2020-08-01' = {
  name: dDOSProtectionPlan1_var
  location: cmLocation2
  properties: {
  }
}

resource networkSecurityGroup1 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: networkSecurityGroup1_var
  location: cmLocation2
  properties: {
    securityRules: []
  }
}

resource networkSecurityGroup2 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: networkSecurityGroup2_var
  location: cmLocation2
  properties: {
    securityRules: []
  }
}

resource networkSecurityGroup3 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: networkSecurityGroup3_var
  location: cmLocation2
  properties: {
    securityRules: []
  }
}

resource sQLServer1 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: sQLServer1_var
  location: cmLocation2
  properties: {
    administratorLogin: SqlServerAdminAccountName
    administratorLoginPassword: AzureSqlLoginPassword
  }
}

resource containerRegistry1 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: containerRegistry1_var
  location: cmLocation2
  properties: {
    adminUserEnabled: false
  }
  sku: {
    name: 'Premium'
  }
}

resource networkSecurityGroup4 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: networkSecurityGroup4_var
  location: cmLocation2
  properties: {
    securityRules: [
      {
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          sourceAddressPrefixes: []
          destinationAddressPrefix: '*'
          destinationAddressPrefixes: []
          sourcePortRanges: []
          destinationPortRanges: []
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
        name: 'AllowHttpsInBound'
      }
      {
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'GatewayManager'
          sourceAddressPrefixes: []
          destinationAddressPrefix: '*'
          destinationAddressPrefixes: []
          sourcePortRanges: []
          destinationPortRanges: []
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
        name: 'AllowGatewayManagerInbound'
      }
      {
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourceAddressPrefixes: []
          destinationAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefixes: []
          sourcePortRanges: []
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          access: 'Allow'
          priority: 150
          direction: 'Inbound'
        }
        name: 'AllowBastionHostCommunicationInBound'
      }
      {
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourceAddressPrefixes: []
          destinationAddressPrefix: '*'
          destinationAddressPrefixes: []
          sourcePortRanges: []
          destinationPortRanges: []
          access: 'Allow'
          priority: 140
          direction: 'Inbound'
        }
        name: 'AllowLoadBalancerInBound'
      }
      {
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          sourceAddressPrefixes: []
          destinationAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefixes: []
          sourcePortRanges: []
          destinationPortRanges: [
            '22'
            '3389'
          ]
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
        name: 'AllowSshRdpOutBound'
      }
      {
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          sourceAddressPrefixes: []
          destinationAddressPrefix: 'AzureCloud'
          destinationAddressPrefixes: []
          sourcePortRanges: []
          destinationPortRanges: []
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
        name: 'AllowAzureCloudCommunicationOutBound'
      }
      {
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourceAddressPrefixes: []
          destinationAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefixes: []
          sourcePortRanges: []
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
        name: 'AllowBastionHostCommunicationOutBound'
      }
      {
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          sourceAddressPrefixes: []
          destinationAddressPrefix: 'Internet'
          destinationAddressPrefixes: []
          sourcePortRanges: []
          destinationPortRanges: [
            '80'
            '443'
          ]
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
        name: 'AllowGetSessionInformationOutBound'
      }
    ]
  }
}

resource publicIpAddress1 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: publicIpAddress1_var
  location: cmLocation2
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    ipTags: []
  }
  zones: []
}

resource networkSecurityGroup5 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: networkSecurityGroup5_var
  location: cmLocation2
  properties: {
    securityRules: []
  }
}

resource webServerfarm1 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: webServerfarm1_var
  location: cmLocation2
  properties: {
    targetWorkerCount: 1
    targetWorkerSizeId: 1
  }
  sku: {
    capacity: 1
    name: 'S2'
  }
}

resource AppServiceName_resource 'Microsoft.Web/sites@2020-12-01' = {
  name: AppServiceName
  identity: {
    type: 'SystemAssigned'
  }
  location: cmLocation2
  properties: {
    clientAffinityEnabled: false
    httpsOnly: true
    serverFarmId: resourceId(resourceGroup1, 'Microsoft.Web/serverfarms', webServerfarm1_var)
    siteConfig: {
      alwaysOn: true
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(resourceId(resourceGroup1, 'Microsoft.Insights/components', applicationInsights1_var), '2015-05-01', 'Full').properties.InstrumentationKey
        }
      ]
      connectionStrings: []
      defaultDocuments: []
      handlerMappings: []
      httpLoggingEnabled: false
      ipSecurityRestrictions: []
      minTlsVersion: '1.2'
      remoteDebuggingEnabled: false
      scmIpSecurityRestrictions: []
      vnetRouteAllEnabled: true
      webSocketsEnabled: false
    }
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Web/serverfarms', webServerfarm1_var)
    resourceId(resourceGroup1, 'Microsoft.Insights/components', applicationInsights1_var)
  ]
}

resource networkPrivateDnsZone1 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: networkPrivateDnsZone1_var
  location: 'global'
}

resource networkPrivateDnsZone2 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: networkPrivateDnsZone2_var
  location: 'global'
}

resource networkPrivateDnsZone3 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: networkPrivateDnsZone3_var
  location: 'global'
}

resource networkPrivateDnsZone4 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: networkPrivateDnsZone4_var
  location: 'global'
}

resource publicIpAddress2 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: publicIpAddress2_var
  location: cmLocation2
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    ipTags: []
  }
  zones: []
}

resource networkPrivateDnsZone5 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: networkPrivateDnsZone5_var
  location: 'global'
}

resource networkPrivateDnsZone6 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: networkPrivateDnsZone6_var
  location: 'global'
}

resource cDNProfileFrontDoor1 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: cDNProfileFrontDoor1_var
  location: 'global'
  properties: {
  }
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
}

resource SpokeVnetName_resource 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: SpokeVnetName
  location: cmLocation2
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.240.0.0/20'
      ]
    }
    subnets: [
      {
        name: subnet1
        properties: {
          addressPrefix: '10.240.11.0/24'
          networkSecurityGroup: {
            id: resourceId(resourceGroup1, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroup1_var)
          }
          serviceEndpoints: []
          serviceEndpointPolicies: []
          delegations: []
        }
      }
      {
        name: subnet2
        properties: {
          addressPrefix: '10.240.0.0/26'
          networkSecurityGroup: {
            id: resourceId(resourceGroup1, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroup2_var)
          }
          serviceEndpoints: []
          serviceEndpointPolicies: []
          delegations: [
            {
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
              name: 'appservicedelegation'
            }
          ]
        }
      }
      {
        name: subnet3
        properties: {
          addressPrefix: '10.240.0.64/26'
          networkSecurityGroup: {
            id: resourceId(resourceGroup1, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroup3_var)
          }
          serviceEndpoints: []
          serviceEndpointPolicies: []
          delegations: []
        }
      }
      {
        name: subnet5
        properties: {
          addressPrefix: '10.240.10.128/26'
          networkSecurityGroup: {
            id: resourceId(resourceGroup1, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroup5_var)
          }
          serviceEndpoints: []
          serviceEndpointPolicies: []
          delegations: []
        }
      }
    ]
    enableDdosProtection: true
    ddosProtectionPlan: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/ddosProtectionPlans', dDOSProtectionPlan1_var)
    }
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroup1_var)
    resourceId(resourceGroup1, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroup2_var)
    resourceId(resourceGroup1, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroup3_var)
    resourceId(resourceGroup1, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroup5_var)
    resourceId(resourceGroup1, 'Microsoft.Network/ddosProtectionPlans', dDOSProtectionPlan1_var)
  ]
}

resource networkPrivateEndpoint1 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: networkPrivateEndpoint1_var
  location: cmLocation2
  properties: {
    subnet: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/subnets', SpokeVnetName, subnet1)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: resourceId(resourceGroup1, 'Microsoft.AppConfiguration/configurationStores', appConfiguration1_var)
          groupIds: [
            'configurationStores'
          ]
        }
        name: 'PrivateLinkServiceappconfig'
      }
    ]
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    resourceId(resourceGroup1, 'Microsoft.AppConfiguration/configurationStores', appConfiguration1_var)
  ]
}

resource networkPrivateEndpoint2 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: networkPrivateEndpoint2_var
  location: cmLocation2
  properties: {
    subnet: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/subnets', SpokeVnetName, subnet1)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: resourceId(resourceGroup1, 'Microsoft.ContainerRegistry/registries', containerRegistry1_var)
          groupIds: [
            'registry'
          ]
        }
        name: 'PrivateLinkServicecr'
      }
    ]
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    resourceId(resourceGroup1, 'Microsoft.ContainerRegistry/registries', containerRegistry1_var)
  ]
}

resource HubVNetName_resource 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: HubVNetName
  location: cmLocation2
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.242.0.0/20'
      ]
    }
    subnets: [
      {
        name: subnet4
        properties: {
          addressPrefix: '10.242.0.64/26'
          networkSecurityGroup: {
            id: resourceId(resourceGroup1, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroup4_var)
          }
          serviceEndpoints: []
          serviceEndpointPolicies: []
          delegations: []
        }
      }
      {
        name: subnet6
        properties: {
          addressPrefix: '10.242.0.0/26'
          serviceEndpoints: []
          serviceEndpointPolicies: []
          delegations: []
        }
      }
    ]
    enableDdosProtection: false
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroup4_var)
  ]
}

resource bastion1 'Microsoft.Network/bastionHosts@2021-05-01' = {
  name: bastion1_var
  location: cmLocation2
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/subnets', HubVNetName, subnet4)
          }
          publicIPAddress: {
            id: resourceId(resourceGroup1, 'Microsoft.Network/publicIPAddresses', publicIpAddress1_var)
          }
        }
      }
    ]
    scaleUnits: 2
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
    resourceId(resourceGroup1, 'Microsoft.Network/publicIPAddresses', publicIpAddress1_var)
  ]
}

resource AppServiceName_appServiceConfigRegionalVirtualNetworkIntegration1 'Microsoft.Web/sites/config@2018-11-01' = {
  parent: AppServiceName_resource
  name: '${appServiceConfigRegionalVirtualNetworkIntegration1}'
  properties: {
    subnetResourceId: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/subnets', SpokeVnetName, subnet2)
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    resourceId(resourceGroup1, 'Microsoft.Web/sites', AppServiceName)
  ]
}

resource networkFirewall1 'Microsoft.Network/azureFirewalls@2022-01-01' = {
  name: networkFirewall1_var
  location: cmLocation2
  properties: {
    ipConfigurations: [
      {
        name: 'AFWIpConfig'
        properties: {
          publicIPAddress: {
            id: resourceId(resourceGroup1, 'Microsoft.Network/publicIPAddresses', publicIpAddress2_var)
          }
          subnet: {
            id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/subnets', HubVNetName, subnet6)
          }
        }
      }
    ]
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
  }
  zones: []
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/publicIPAddresses', publicIpAddress2_var)
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
  ]
}

resource networkPrivateEndpoint3 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: networkPrivateEndpoint3_var
  location: cmLocation2
  properties: {
    subnet: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/subnets', SpokeVnetName, subnet1)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: resourceId(resourceGroup1, 'Microsoft.Sql/servers', sQLServer1_var)
          groupIds: [
            'sqlServer'
          ]
        }
        name: 'PrivateLinkServicesql'
      }
    ]
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    resourceId(resourceGroup1, 'Microsoft.Sql/servers', sQLServer1_var)
  ]
}

resource networkPrivateEndpoint4 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: networkPrivateEndpoint4_var
  location: cmLocation2
  properties: {
    subnet: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/subnets', SpokeVnetName, subnet1)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: resourceId(resourceGroup1, 'Microsoft.KeyVault/vaults', keyVault1_var)
          groupIds: [
            'vault'
          ]
        }
        name: 'PrivateLinkServicekv'
      }
    ]
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    resourceId(resourceGroup1, 'Microsoft.KeyVault/vaults', keyVault1_var)
  ]
}

resource networkPrivateEndpoint5 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: networkPrivateEndpoint5_var
  location: cmLocation2
  properties: {
    subnet: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/subnets', SpokeVnetName, subnet3)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: resourceId(resourceGroup1, 'Microsoft.Web/sites', AppServiceName)
          groupIds: [
            'sites'
          ]
        }
        name: 'PrivateLinkServiceAppSVc'
      }
    ]
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    resourceId(resourceGroup1, 'Microsoft.Web/sites', AppServiceName)
  ]
}

resource cDNProfileFrontDoor1_cDNProfileFrontDoorEndpoint1 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  parent: cDNProfileFrontDoor1
  name: '${cDNProfileFrontDoorEndpoint1}'
  location: 'global'
  properties: {
    autoGeneratedDomainNameLabelScope: 'ResourceGroupReuse'
    enabledState: 'Enabled'
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Cdn/profiles', cDNProfileFrontDoor1_var)
  ]
}

resource cDNProfileFrontDoor1_cDNProfileFrontDoorOriginGroup1 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  parent: cDNProfileFrontDoor1
  name: '${cDNProfileFrontDoorOriginGroup1}'
  properties: {
    healthProbeSettings: {
      probeProtocol: 'Http'
      probeRequestType: 'GET'
    }
    loadBalancingSettings: {
      additionalLatencyInMilliseconds: 500
      sampleSize: 10
      successfulSamplesRequired: 5
    }
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Cdn/profiles', cDNProfileFrontDoor1_var)
  ]
}

resource SpokeVnetName_networkVirtualNetworkVirtualNetworkPeering1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  parent: SpokeVnetName_resource
  name: '${networkVirtualNetworkVirtualNetworkPeering1}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
    }
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
  ]
}

resource HubVNetName_networkVirtualNetworkVirtualNetworkPeering2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  parent: HubVNetName_resource
  name: '${networkVirtualNetworkVirtualNetworkPeering2}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    }
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
  ]
}

resource networkPrivateDnsZone1_networkPrivateDnsZoneVirtualNetworkLink1 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone1
  name: '${networkPrivateDnsZoneVirtualNetworkLink1}'
  properties: {
    virtualNetwork: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings', HubVNetName, networkVirtualNetworkVirtualNetworkPeering2)
    resourceId(resourceGroup1, 'Microsoft.Network/privateDnsZones', networkPrivateDnsZone1_var)
  ]
}

resource networkPrivateDnsZone1_networkPrivateDnsZoneVirtualNetworkLink2 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone1
  name: '${networkPrivateDnsZoneVirtualNetworkLink2}'
  properties: {
    virtualNetwork: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings', SpokeVnetName, networkVirtualNetworkVirtualNetworkPeering1)
    resourceId(resourceGroup1, 'Microsoft.Network/privateDnsZones', networkPrivateDnsZone1_var)
  ]
}

resource networkPrivateDnsZone2_networkPrivateDnsZoneVirtualNetworkLink3 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone2
  name: '${networkPrivateDnsZoneVirtualNetworkLink3}'
  properties: {
    virtualNetwork: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings', HubVNetName, networkVirtualNetworkVirtualNetworkPeering2)
    resourceId(resourceGroup1, 'Microsoft.Network/privateDnsZones', networkPrivateDnsZone2_var)
  ]
}

resource networkPrivateDnsZone2_networkPrivateDnsZoneVirtualNetworkLink4 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone2
  name: '${networkPrivateDnsZoneVirtualNetworkLink4}'
  properties: {
    virtualNetwork: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings', SpokeVnetName, networkVirtualNetworkVirtualNetworkPeering1)
    resourceId(resourceGroup1, 'Microsoft.Network/privateDnsZones', networkPrivateDnsZone2_var)
  ]
}

resource networkPrivateDnsZone3_networkPrivateDnsZoneVirtualNetworkLink5 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone3
  name: '${networkPrivateDnsZoneVirtualNetworkLink5}'
  properties: {
    virtualNetwork: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings', SpokeVnetName, networkVirtualNetworkVirtualNetworkPeering1)
    resourceId(resourceGroup1, 'Microsoft.Network/privateDnsZones', networkPrivateDnsZone3_var)
  ]
}

resource networkPrivateDnsZone3_networkPrivateDnsZoneVirtualNetworkLink6 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone3
  name: '${networkPrivateDnsZoneVirtualNetworkLink6}'
  properties: {
    virtualNetwork: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings', HubVNetName, networkVirtualNetworkVirtualNetworkPeering2)
    resourceId(resourceGroup1, 'Microsoft.Network/privateDnsZones', networkPrivateDnsZone3_var)
  ]
}

resource networkPrivateDnsZone4_networkPrivateDnsZoneVirtualNetworkLink7 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone4
  name: '${networkPrivateDnsZoneVirtualNetworkLink7}'
  properties: {
    virtualNetwork: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings', HubVNetName, networkVirtualNetworkVirtualNetworkPeering2)
    resourceId(resourceGroup1, 'Microsoft.Network/privateDnsZones', networkPrivateDnsZone4_var)
  ]
}

resource networkPrivateDnsZone4_networkPrivateDnsZoneVirtualNetworkLink8 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone4
  name: '${networkPrivateDnsZoneVirtualNetworkLink8}'
  properties: {
    virtualNetwork: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings', SpokeVnetName, networkVirtualNetworkVirtualNetworkPeering1)
    resourceId(resourceGroup1, 'Microsoft.Network/privateDnsZones', networkPrivateDnsZone4_var)
  ]
}

resource networkPrivateDnsZone5_networkPrivateDnsZoneVirtualNetworkLink9 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone5
  name: '${networkPrivateDnsZoneVirtualNetworkLink9}'
  properties: {
    virtualNetwork: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings', HubVNetName, networkVirtualNetworkVirtualNetworkPeering2)
    resourceId(resourceGroup1, 'Microsoft.Network/privateDnsZones', networkPrivateDnsZone5_var)
  ]
}

resource networkPrivateDnsZone5_networkPrivateDnsZoneVirtualNetworkLink10 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone5
  name: '${networkPrivateDnsZoneVirtualNetworkLink10}'
  properties: {
    virtualNetwork: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings', SpokeVnetName, networkVirtualNetworkVirtualNetworkPeering1)
    resourceId(resourceGroup1, 'Microsoft.Network/privateDnsZones', networkPrivateDnsZone5_var)
  ]
}

resource networkPrivateDnsZone6_networkPrivateDnsZoneVirtualNetworkLink11 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone6
  name: '${networkPrivateDnsZoneVirtualNetworkLink11}'
  properties: {
    virtualNetwork: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', SpokeVnetName)
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings', SpokeVnetName, networkVirtualNetworkVirtualNetworkPeering1)
    resourceId(resourceGroup1, 'Microsoft.Network/privateDnsZones', networkPrivateDnsZone6_var)
  ]
}

resource networkPrivateDnsZone6_networkPrivateDnsZoneVirtualNetworkLink12 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone6
  name: '${networkPrivateDnsZoneVirtualNetworkLink12}'
  properties: {
    virtualNetwork: {
      id: resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks', HubVNetName)
    resourceId(resourceGroup1, 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings', HubVNetName, networkVirtualNetworkVirtualNetworkPeering2)
    resourceId(resourceGroup1, 'Microsoft.Network/privateDnsZones', networkPrivateDnsZone6_var)
  ]
}

resource cDNProfileFrontDoor1_cDNProfileFrontDoorOriginGroup1_cDNProfileFrontDoorOriginGroupOrigin1 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  parent: cDNProfileFrontDoor1_cDNProfileFrontDoorOriginGroup1
  name: cDNProfileFrontDoorOriginGroupOrigin1
  properties: {
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
    hostName: '${AppServiceName}.azurewebsites.net'
    httpPort: 80
    httpsPort: 443
    originHostHeader: '${AppServiceName}.azurewebsites.net'
    priority: 1
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Cdn/profiles/originGroups', cDNProfileFrontDoor1_var, cDNProfileFrontDoorOriginGroup1)
  ]
}

resource cDNProfileFrontDoor1_cDNProfileFrontDoorEndpoint1_cDNProfileFrontDoorEndpointsRoute1 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  parent: cDNProfileFrontDoor1_cDNProfileFrontDoorEndpoint1
  name: cDNProfileFrontDoorEndpointsRoute1
  properties: {
    customDomains: []
    enabledState: 'Enabled'
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    originGroup: {
      id: resourceId(resourceGroup1, 'Microsoft.Cdn/profiles/originGroups', cDNProfileFrontDoor1_var, cDNProfileFrontDoorOriginGroup1)
    }
    originPath: '/*'
    patternsToMatch: []
    ruleSets: []
    supportedProtocols: []
  }
  dependsOn: [
    resourceId(resourceGroup1, 'Microsoft.Cdn/profiles/originGroups', cDNProfileFrontDoor1_var, cDNProfileFrontDoorOriginGroup1)
    resourceId(resourceGroup1, 'Microsoft.Cdn/profiles/originGroups/origins', cDNProfileFrontDoor1_var, cDNProfileFrontDoorOriginGroup1, cDNProfileFrontDoorOriginGroupOrigin1)
    resourceId(resourceGroup1, 'Microsoft.Cdn/profiles/afdEndpoints', cDNProfileFrontDoor1_var, cDNProfileFrontDoorEndpoint1)
  ]
}
