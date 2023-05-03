@description('Required. Name given for the hub route table.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. An Array of Routes to be established within the hub route table.')
param routes array = []

@description('Optional. Switch to disable BGP route propagation.')
param disableBgpRoutePropagation bool = false

@description('Optional. Tags of the resource.')
param tags object = {}


// example: 
// routes: [
//       {
//         name: 'default'
//         properties: {
//           addressPrefix: '0.0.0.0/0'
//           nextHopIpAddress: '172.16.0.20'
//           nextHopType: 'VirtualAppliance'
//         }
//       }
//     ]


resource routeTable 'Microsoft.Network/routeTables@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    routes: routes
    disableBgpRoutePropagation: disableBgpRoutePropagation
  }
}

@description('The resource group the route table was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The name of the route table.')
output name string = routeTable.name

@description('The resource ID of the route table.')
output resourceId string = routeTable.id

@description('The location the resource was deployed into.')
output location string = routeTable.location
