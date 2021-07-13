param namePrefix string = 'unique'
param location string = resourceGroup().location
param subnetId string
param osDiskType string = 'Standard_LRS'
param vmSize string = 'Standard_D4_v3'
param username string
param password string
param windowsOSVersion string = '2016-Datacenter'
//var vmName = '${namePrefix}${uniqueString(resourceGroup().id)}'
param vmName string
param deployAgent bool=false

@description('The Visual Studio Team Services account name, that is, the first part of your VSTSAccount.visualstudio.com')
param vstsAccount string=''

@description('The personal access token to connect to VSTS')
@secure()
param personalAccessToken string=''

@description('The Visual Studio Team Services build agent pool for this build agent to join. Use \'Default\' if you don\'t have a separate pool.')
param poolName string = 'Default'

@description('Enable autologon to run the build agent in interactive mode that can sustain machine reboots.<br>Set this to true if the agents will be used to run UI tests.')
param enableAutologon bool = false
@description('The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')
param artifactsLocation string = 'https://raw.githubusercontent.com/ahmedsza/azdevopsagent/main/'

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param artifactsLocationSasToken string = ''

var vstsAgentName = 'agent-${vmName}'
//var vstsParameters = '-vstsAccount ${vstsAccount} -personalAccessToken ${personalAccessToken} -AgentName ${vstsAgentName} -PoolName ${poolName} -runAsAutoLogon ${enableAutologon} -vmAdminUserName ${username} -vmAdminPassword ${password}'
var vstsParameters = '-url ${vstsAccount} -pat ${personalAccessToken} -agent ${vstsAgentName} -pool ${poolName}'


// Bring in the nic
module nic './vm-nic.bicep' = {
  name: '${vmName}-nic'
  params: {
    namePrefix: '${vmName}-hdd'
    subnetId: subnetId
    vmName: vmName
  }
}

// Create the vm
resource vm 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: vmName
  location: location
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: windowsOSVersion
        version: 'latest'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: username
      adminPassword: password
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.outputs.nicId
        }
      ]
    }
  }
}

resource vm_CustomScript 'Microsoft.Compute/virtualMachines/extensions@2018-06-01' = if (deployAgent) {
  parent: vm
  name: 'CustomScript'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/ahmedsza/azdevopsagent/main/setupagent.ps1'
      ]   
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -Command ./setupagent.ps1 -url ${vstsAccount} -pat ${personalAccessToken} -agent ${vstsAgentName} -pool ${poolName}'
    }
  }
}


output id string = vm.id
