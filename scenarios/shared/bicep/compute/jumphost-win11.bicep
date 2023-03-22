//TODO: needs some expansion to have less hardcoded things tt20230214

@description('Name of the resource Virtual Network (The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens)')
@minLength(2)
@maxLength(64)
param name string

@description('Name of the windows PC. Optional, by default gets automatically constructed by the resource name. Use it to give more meaningful names, or avoid conflicts')
@maxLength(15)
param computerWindowsName string = ''

@description('Azure Region where the resource will be deployed in')
param location string

@description('key-value pairs as tags, to identify the resource')
param tags object

@description('The subnet where the VM will be attached to')
param subnetId string

@description('optional, default value is azureuser')
param adminUsername string = 'azureuser'

@description('mandatory, the password of the admin user')
@secure()
param adminPassword string

param enableAzureAdJoin bool = true

@description('optional, default value is Standard_B2ms')
param vmSize string = 'Standard_B2ms'

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

var aadLoginExtensionName = 'AADLoginForWindows'

var vmNameMaxLength = 64
var vmName = length(name) > vmNameMaxLength ? substring(name, 0, vmNameMaxLength) : name

var computerNameLength = 15
var computerNameValid = replace( replace(name, '-', ''), '_', '')
var computerName = length(computerNameValid) > computerNameLength ? substring(computerNameValid, 0, computerNameLength) : computerNameValid

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

module jumphostNic '../network/nic.private.dynamic.bicep' = {
  name: 'jumphostNicDeployment'
  params: {
    name: 'nic-${vmName}'
    subnetId: subnetId
    location: location
    tags: tags
  }
}

resource jumphost 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: location
  tags: tags
  identity: identity
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-11'
        sku: 'win11-22h2-pro'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: empty(computerWindowsName) ? computerName : computerWindowsName
      adminUsername: adminUsername
      adminPassword: adminPassword      
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
        enableVMAgentPlatformUpdates: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: jumphostNic.outputs.nicId
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource virtualMachineName_aadLoginExtensionName 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = if (enableAzureAdJoin) {
  parent: jumphost
  name: aadLoginExtensionName
  location: location
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: aadLoginExtensionName
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}
