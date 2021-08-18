
param location string = resourceGroup().location
param subnetId string
param osDiskType string = 'Standard_LRS'
param vmSize string = 'Standard_D4_v3'
param username string
param password string
param windowsOSVersion string = '2016-Datacenter'
param vmName string
param deployAgent bool=false

@description('The Azure DevOps or GitHub account name]')
param accountname string=''

@description('The personal access token to connect to Azure DevOps or Github')
@secure()
param personalAccessToken string=''

@description('The Azure DevOps or GitHub pool for this build agent to join. Use \'Default\' if you don\'t have a separate pool.')
param poolName string = 'Default'

@description('Is this Azure Devops or GitHub.')
param orgtype string


@description('The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')
param artifactsLocation string = 'https://raw.githubusercontent.com/cykreng/Enterprise-Scale-AppService/main/deployment/bicep/shared/agentsetup.ps1'



var AgentName = 'agent-${vmName}'

// Bring in the nic
module nic './vm-nic.bicep' = {
  name: '${vmName}-nic'
  params: {
    subnetId: subnetId
    vmName: vmName
  }
}

// Create the vm
resource vm 'Microsoft.Compute/virtualMachines@2021-04-01' = {
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

resource vm_CustomScript 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = if (deployAgent) {
  parent: vm
  name: 'CustomScript'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    settings: {
      fileUris: [
        artifactsLocation
      ]   
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -Command ./agentsetup.ps1 -url ${accountname} -pat ${personalAccessToken} -agent ${AgentName} -pool ${poolName} -agenttype ${orgtype} '
    }
  }
}


output id string = vm.id
