
param AppServiceName string 

@secure()
param VmAdminPassword string 
@secure()
param AzureSqlLoginPassword string
param ContainerRegistryName string 
param HubVNetName string 
param ResourceGroupLocation string 
param SpokeVnetName string
param SqlServerAdminAccountName string
var cmLocation1  = ResourceGroupLocation
var VmAdminUserName =SqlServerAdminAccountName

var AppConfigResourceName = '${AppServiceName}-appcs'
var AppInsightResourceName = '${AppServiceName}-appi'
var BastionResourceName = '${HubVNetName}-bas'
var CdnProfileFrontDoorResource = '${AppServiceName}-afd'
var cDNProfileFrontDoorEndpoint1 = '${CdnProfileFrontDoorResource}-fde'
var cDNProfileFrontDoorEndpointsRoute1 = '${CdnProfileFrontDoorResource}-route'
var cDNProfileFrontDoorOriginGroup1 = '${CdnProfileFrontDoorResource}-AfdAsOG'
var cDNProfileFrontDoorOriginGroupOrigin1 = '${CdnProfileFrontDoorResource}-origin'
var KeyVaultResourceName = '${AppServiceName}-kv'
var AzureFireWallResourceName = '${HubVNetName}-afw'
var AzureVNetInterface = '${VirtualMachineDevOpsResource}-interface'
var networkInterfaceIPConfiguration1 = 'config1'
var AzConfigPrivateLink = 'privatelink.azconfig.io'
var VaultCorePrivateLink = 'privatelink.vaultcore.azure.net'
var AzurewebsitesPrivateLink = 'privatelink.azurewebsites.net'
var AzureCRPrivateLink = 'privatelink.azurecr.io'
var azuresqlendpoint = environment().suffixes.sqlServerHostname
var AzureSqlDBPrivateLink = 'privatelink${azuresqlendpoint}'


var RedisPrivateLink = 'privatelink.redis.cache.windows.net'
var networkPrivateDnsZoneVirtualNetworkLink1 = 'spoke'
var networkPrivateDnsZoneVirtualNetworkLink10 = 'HubAppService'
var networkPrivateDnsZoneVirtualNetworkLink11 = 'hub'
var networkPrivateDnsZoneVirtualNetworkLink12 = 'hub'
var networkPrivateDnsZoneVirtualNetworkLink2 = 'spoke'
var networkPrivateDnsZoneVirtualNetworkLink3 = 'SpokeAppService'
var networkPrivateDnsZoneVirtualNetworkLink4 = 'spoke'
var networkPrivateDnsZoneVirtualNetworkLink5 = 'spoke'
var networkPrivateDnsZoneVirtualNetworkLink6 = 'hub'
var networkPrivateDnsZoneVirtualNetworkLink7 = 'spoke'
var networkPrivateDnsZoneVirtualNetworkLink8 = 'hub'
var networkPrivateDnsZoneVirtualNetworkLink9 = 'hub'
var appcspepPrivateEndpoint = '${SpokeVnetName}-appcspep'
var crpepPrivateEndpoint = '${SpokeVnetName}-crpep'
var sqldbpepPrivateEndpoint = '${SpokeVnetName}-sqldbpep'
var kvpepPrivateEndpoint = '${SpokeVnetName}-kvpep'
var AppSVCPrivateEndpoint = '${SpokeVnetName}-AppSVC'
var networkSecurityGroup1Subnet1 = '${subnet1}-nsg'
var networkSecurityGroup1Subnet2 = '${subnet2}-nsg'
var networkSecurityGroup1Subnet3 = '${subnet3}-nsg'
var networkSecurityGroup1Subnet4 = '${subnet4}-nsg'
var networkSecurityGroup1Subnet5 = '${subnet5}-nsg'
var networkVirtualNetworkVirtualNetworkPeering1 = 'HubPeering'
var networkVirtualNetworkVirtualNetworkPeering2 = 'Spoke'
var LogAnalyticsResoourceName = '${AppServiceName}-log'
var AzureFireWallPipResourceName = 'AzFirewallpip'
var PublicIpResourceName = '${subnet4}-PIP'
var AzureRedisResourceName = '${AppServiceName}-redis'
var AzureSqlResourceName = '${AppServiceName}-sql'
var subnet1 = '${SpokeVnetName}-pepsnet'
var subnet2 = '${SpokeVnetName}-Spokevnet'
var subnet3 = '${SpokeVnetName}-Vmss-vnet'
var subnet4 = 'AzureBastionSubnet'
var subnet5 = '${SpokeVnetName}-AFDSubnet'
var subnet6 = 'AzureFirewallSubnet'
var VirtualMachineDevOpsResource = '${AppServiceName}-DevOpsvm'
var virtualMachineOSDiskWindows1 = 'OsDisk'
var AzureSpokeVnetResourceName = SpokeVnetName
var AzureHubVnetResourceName = HubVNetName
var AppServicePlanResourceName = '${AppServiceName}-asp'

resource keyVault1 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: KeyVaultResourceName
  location: cmLocation1
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
  name: AppConfigResourceName
  location: cmLocation1
  properties: {
  }
  sku: {
    name: 'Standard'
  }
}

resource operationalInsightsWorkspace1 'Microsoft.OperationalInsights/workspaces@2015-11-01-preview' = {
  name: LogAnalyticsResoourceName
  location: cmLocation1
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource networkSecurityGroup1 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: networkSecurityGroup1Subnet1
  location: cmLocation1
  properties: {
    securityRules: []
  }
}

resource networkSecurityGroup2 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: networkSecurityGroup1Subnet2
  location: cmLocation1
  properties: {
    securityRules: []
  }
}

resource sQLServer1 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: AzureSqlResourceName
  location: cmLocation1
  properties: {
    administratorLogin: SqlServerAdminAccountName
    administratorLoginPassword: AzureSqlLoginPassword
  }
}

resource ContainerRegistryName_resource 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: ContainerRegistryName
  location: cmLocation1
  properties: {
    adminUserEnabled: false
  }
  sku: {
    name: 'Premium'
  }
}

resource networkSecurityGroup3 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: networkSecurityGroup1Subnet3
  location: cmLocation1
  properties: {
    securityRules: []
  }
}

resource webServerfarm1 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: AppServicePlanResourceName
  location: cmLocation1
  properties: {
    targetWorkerCount: 1
    targetWorkerSizeId: 1
  }
  sku: {
    capacity: 1
    name: 'S2'
  }
}

resource networkPrivateDnsZone1 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: AzConfigPrivateLink
  location: 'global'
}

resource networkPrivateDnsZone2 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: VaultCorePrivateLink
  location: 'global'
}

resource networkPrivateDnsZone3 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: AzurewebsitesPrivateLink
  location: 'global'
}

resource networkPrivateDnsZone4 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: AzureCRPrivateLink
  location: 'global'
}

resource redisCache1 'Microsoft.Cache/Redis@2017-10-01' = {
  name: AzureRedisResourceName
  location: cmLocation1
  properties: {
    sku: {
      capacity: 0
      family: 'C'
      name: 'Standard'
    }
  }
}

resource cDNProfileFrontDoor1 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: CdnProfileFrontDoorResource
  location: 'global'
  properties: {
  }
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
}

resource networkPrivateDnsZone5 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: AzureSqlDBPrivateLink
  location: 'global'
}

resource networkSecurityGroup4 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: networkSecurityGroup1Subnet4
  location: cmLocation1
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
  name: AzureFireWallPipResourceName
  location: cmLocation1
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

resource publicIpAddress2 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: PublicIpResourceName
  location: cmLocation1
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
  name: networkSecurityGroup1Subnet5
  location: cmLocation1
  properties: {
    securityRules: []
  }
}

resource networkPrivateDnsZone6 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: RedisPrivateLink
  location: 'global'
}

resource applicationInsights1 'Microsoft.Insights/components@2015-05-01' = {
  name: AppInsightResourceName
  location: cmLocation1
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

resource virtualNetwork1 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: AzureSpokeVnetResourceName
  location: cmLocation1
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
            id: networkSecurityGroup1.id
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
            id: networkSecurityGroup2.id
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
          addressPrefix: '10.240.10.128/26'
          networkSecurityGroup: {
            id: networkSecurityGroup3.id
          }
          serviceEndpoints: []
          serviceEndpointPolicies: []
          delegations: []
        }
      }
      {
        name: subnet5
        properties: {
          addressPrefix: '10.240.0.64/26'
          networkSecurityGroup: {
            id: networkSecurityGroup5.id
          }
          serviceEndpoints: []
          serviceEndpointPolicies: []
          delegations: []
        }
      }
    ]
    enableDdosProtection: false
  }
}

resource networkPrivateEndpoint1 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: appcspepPrivateEndpoint
  location: cmLocation1
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', AzureSpokeVnetResourceName, subnet1)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: appConfiguration1.id
          groupIds: [
            'configurationStores'
          ]
        }
        name: 'PrivateLinkServiceappconfig'
      }
    ]
  }
  dependsOn: [
    virtualNetwork1

  ]
}

resource networkPrivateEndpoint2 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: crpepPrivateEndpoint
  location: cmLocation1
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', AzureSpokeVnetResourceName, subnet1)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: ContainerRegistryName_resource.id
          groupIds: [
            'registry'
          ]
        }
        name: 'PrivateLinkServicecr'
      }
    ]
  }
  dependsOn: [
    virtualNetwork1

  ]
}

resource AppServiceName_resource 'Microsoft.Web/sites@2020-12-01' = {
  name: AppServiceName
  identity: {
    type: 'SystemAssigned'
  }
  location: cmLocation1
  properties: {
    clientAffinityEnabled: false
    virtualNetworkSubnetId :  resourceId('Microsoft.Network/virtualNetworks/subnets', AzureSpokeVnetResourceName, subnet2)
    httpsOnly: true
    serverFarmId: webServerfarm1.id
    siteConfig: {
      alwaysOn: true
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(applicationInsights1.id, '2015-05-01', 'Full').properties.InstrumentationKey
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
}

resource networkPrivateEndpoint3 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: sqldbpepPrivateEndpoint
  location: cmLocation1
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', AzureSpokeVnetResourceName, subnet1)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: sQLServer1.id
          groupIds: [
            'sqlServer'
          ]
        }
        name: 'PrivateLinkServicesql'
      }
    ]
  }
  dependsOn: [
    virtualNetwork1

  ]
}

resource networkPrivateEndpoint4 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: kvpepPrivateEndpoint
  location: cmLocation1
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', AzureSpokeVnetResourceName, subnet1)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: keyVault1.id
          groupIds: [
            'vault'
          ]
        }
        name: 'PrivateLinkServicekv'
      }
    ]
  }
  dependsOn: [
    virtualNetwork1

  ]
}

resource networkInterface1 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: AzureVNetInterface
  location: cmLocation1
  properties: {
    ipConfigurations: [
      {
        properties: {
          loadBalancerBackendAddressPools: []
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', AzureSpokeVnetResourceName, subnet3)
          }
          applicationSecurityGroups: []
        }
        name: networkInterfaceIPConfiguration1
      }
    ]
    enableIPForwarding: false
  }
  dependsOn: [
    virtualNetwork1
  ]
}

resource virtualMachine1 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: VirtualMachineDevOpsResource
  location: cmLocation1
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface1.id
          properties: {
            deleteOption: 'Delete'
            primary: true
          }
        }
      ]
    }
    osProfile: {
      adminPassword: VmAdminPassword
      adminUsername: VmAdminUserName
      computerName: 'vmname'
      secrets: []
    }
    storageProfile: {
      dataDisks: []
      imageReference: {
        offer: 'WindowsServer'
        publisher: 'MicrosoftWindowsServer'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDisk: {
        name: virtualMachineOSDiskWindows1
        createOption: 'FromImage'
      }
    }
  }
  zones: []
}

resource cDNProfileFrontDoor1_cDNProfileFrontDoorEndpoint1 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  parent: cDNProfileFrontDoor1
  name: cDNProfileFrontDoorEndpoint1
  location: 'global'
  properties: {
    autoGeneratedDomainNameLabelScope: 'ResourceGroupReuse'
    enabledState: 'Enabled'
  }
}

resource cDNProfileFrontDoor1_cDNProfileFrontDoorOriginGroup1 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  parent: cDNProfileFrontDoor1
  name: cDNProfileFrontDoorOriginGroup1
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
}

resource virtualNetwork2 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: AzureHubVnetResourceName
  location: cmLocation1
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
            id: networkSecurityGroup4.id
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
}

resource networkFirewall1 'Microsoft.Network/azureFirewalls@2022-01-01' = {
  name: AzureFireWallResourceName
  location: cmLocation1
  properties: {
    ipConfigurations: [
      {
        name: 'AFWIpConfig'
        properties: {
          publicIPAddress: {
            id: publicIpAddress1.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', AzureHubVnetResourceName, subnet6)
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

    virtualNetwork2
  ]
}

resource bastion1 'Microsoft.Network/bastionHosts@2021-05-01' = {
  name: BastionResourceName
  location: cmLocation1
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', AzureHubVnetResourceName, subnet4)
          }
          publicIPAddress: {
            id: publicIpAddress2.id
          }
        }
      }
    ]
    scaleUnits: 2
  }
  dependsOn: [
    virtualNetwork2

  ]
}

resource networkPrivateEndpoint5 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: AppSVCPrivateEndpoint
  location: cmLocation1
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', AzureSpokeVnetResourceName, subnet5)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: AppServiceName_resource.id
          groupIds: [
            'sites'
          ]
        }
        name: 'PrivateLinkServiceAppSVc'
      }
    ]
  }
  dependsOn: [
    virtualNetwork1

  ]
}

resource virtualNetwork1_networkVirtualNetworkVirtualNetworkPeering1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  parent: virtualNetwork1
  name: networkVirtualNetworkVirtualNetworkPeering1
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: virtualNetwork2.id
    }
  }
}


resource networkPrivateDnsZone1_networkPrivateDnsZoneVirtualNetworkLink1 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone1
  name: networkPrivateDnsZoneVirtualNetworkLink1
  properties: {
    virtualNetwork: {
      id: virtualNetwork1.id
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [

    virtualNetwork1_networkVirtualNetworkVirtualNetworkPeering1

  ]
}

resource networkPrivateDnsZone2_networkPrivateDnsZoneVirtualNetworkLink2 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone2
  name: networkPrivateDnsZoneVirtualNetworkLink2
  properties: {
    virtualNetwork: {
      id: virtualNetwork1.id
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [

    virtualNetwork1_networkVirtualNetworkVirtualNetworkPeering1

  ]
}

resource networkPrivateDnsZone3_networkPrivateDnsZoneVirtualNetworkLink3 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone3
  name: networkPrivateDnsZoneVirtualNetworkLink3
  properties: {
    virtualNetwork: {
      id: virtualNetwork1.id
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [

    virtualNetwork1_networkVirtualNetworkVirtualNetworkPeering1

  ]
}

resource networkPrivateDnsZone4_networkPrivateDnsZoneVirtualNetworkLink4 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone4
  name: networkPrivateDnsZoneVirtualNetworkLink4
  properties: {
    virtualNetwork: {
      id: virtualNetwork1.id
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [

    virtualNetwork1_networkVirtualNetworkVirtualNetworkPeering1

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
    sharedPrivateLinkResource: {
      groupId: 'sites'
      privateLink: {
        id: AppServiceName_resource.id
      }
      privateLinkLocation: ResourceGroupLocation
      requestMessage: 'Approve request for App Service ADF PE'
    }
  }
}

resource networkPrivateDnsZone5_networkPrivateDnsZoneVirtualNetworkLink5 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone5
  name: networkPrivateDnsZoneVirtualNetworkLink5
  properties: {
    virtualNetwork: {
      id: virtualNetwork1.id
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [

    virtualNetwork1_networkVirtualNetworkVirtualNetworkPeering1

  ]
}

resource virtualNetwork2_networkVirtualNetworkVirtualNetworkPeering2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  parent: virtualNetwork2
  name: networkVirtualNetworkVirtualNetworkPeering2
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: virtualNetwork1.id
    }
  }
}

resource networkPrivateDnsZone6_networkPrivateDnsZoneVirtualNetworkLink6 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone6
  name: networkPrivateDnsZoneVirtualNetworkLink6
  properties: {
    virtualNetwork: {
      id: virtualNetwork2.id
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [

    virtualNetwork2_networkVirtualNetworkVirtualNetworkPeering2

  ]
}

resource networkPrivateDnsZone6_networkPrivateDnsZoneVirtualNetworkLink7 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone6
  name: networkPrivateDnsZoneVirtualNetworkLink7
  properties: {
    virtualNetwork: {
      id: virtualNetwork1.id
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [

    virtualNetwork1_networkVirtualNetworkVirtualNetworkPeering1

  ]
}

resource networkPrivateDnsZone1_networkPrivateDnsZoneVirtualNetworkLink8 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone1
  name: networkPrivateDnsZoneVirtualNetworkLink8
  properties: {
    virtualNetwork: {
      id: virtualNetwork2.id
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [

    virtualNetwork2_networkVirtualNetworkVirtualNetworkPeering2

  ]
}

resource networkPrivateDnsZone2_networkPrivateDnsZoneVirtualNetworkLink9 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone2
  name: networkPrivateDnsZoneVirtualNetworkLink9
  properties: {
    virtualNetwork: {
      id: virtualNetwork2.id
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [

    virtualNetwork2_networkVirtualNetworkVirtualNetworkPeering2

  ]
}

resource networkPrivateDnsZone3_networkPrivateDnsZoneVirtualNetworkLink10 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone3
  name: networkPrivateDnsZoneVirtualNetworkLink10
  properties: {
    virtualNetwork: {
      id: virtualNetwork2.id
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [

    virtualNetwork2_networkVirtualNetworkVirtualNetworkPeering2

  ]
}

resource networkPrivateDnsZone4_networkPrivateDnsZoneVirtualNetworkLink11 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone4
  name: networkPrivateDnsZoneVirtualNetworkLink11
  properties: {
    virtualNetwork: {
      id: virtualNetwork2.id
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [

    virtualNetwork2_networkVirtualNetworkVirtualNetworkPeering2

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
      id: cDNProfileFrontDoor1_cDNProfileFrontDoorOriginGroup1.id
    }
    originPath: '/*'
    patternsToMatch: []
    ruleSets: []
    supportedProtocols: []
  }
  dependsOn: [

    cDNProfileFrontDoor1_cDNProfileFrontDoorOriginGroup1_cDNProfileFrontDoorOriginGroupOrigin1

  ]
}

resource networkPrivateDnsZone5_networkPrivateDnsZoneVirtualNetworkLink12 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: networkPrivateDnsZone5
  name: networkPrivateDnsZoneVirtualNetworkLink12
  properties: {
    virtualNetwork: {
      id: virtualNetwork2.id
    }
    registrationEnabled: false
  }
  location: 'global'
  dependsOn: [

    virtualNetwork2_networkVirtualNetworkVirtualNetworkPeering2

  ]
}

//  Telemetry Deployment
@description('Enable usage and telemetry feedback to Microsoft.')
param enableTelemetry bool = true
var telemetryId = 'cf7e9f0a-f872-49db-b72f-f2e318189a6d-${cmLocation1}-msb'
resource telemetrydeployment 'Microsoft.Resources/deployments@2021-04-01' = if (enableTelemetry) {
  name: telemetryId
  location: cmLocation1
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#'
      contentVersion: '1.0.0.0'
      resources: {}
    }
  }
}
