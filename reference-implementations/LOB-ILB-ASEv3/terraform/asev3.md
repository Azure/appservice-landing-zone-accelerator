## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service_environment_v3.ase](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_environment_v3) | resource |
| [azurerm_bastion_host.bastionHost](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) | resource |
| [azurerm_private_dns_a_record.privateDnsZoneName_Amp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_a_record.privateDnsZoneName_all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_a_record.privateDnsZoneName_scm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.privateDnsZone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.privateDnsZoneName_vnetLink](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_public_ip.bastionHostPippublicIp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.aserg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.networkrg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.sharedrg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_service_plan.appServicePlan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_subnet.vnetSpokeSubnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.vnetHub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network.vnetSpoke](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.peerhubtospoke](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.peerspoketohub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_CICDAgentNameAddressPrefix"></a> [CICDAgentNameAddressPrefix](#input\_CICDAgentNameAddressPrefix) | CIDR prefix to use for Spoke VNet | `string` | `"10.0.2.0/24"` | no |
| <a name="input_aseAddressPrefix"></a> [aseAddressPrefix](#input\_aseAddressPrefix) | CIDR prefix to use for ASE | `string` | `"10.1.1.0/24"` | no |
| <a name="input_bastionAddressPrefix"></a> [bastionAddressPrefix](#input\_bastionAddressPrefix) | CIDR prefix to use for Hub VNet | `string` | `"10.0.1.0/24"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment for which the deployment is being executed | `string` | `"dev"` | no |
| <a name="input_hubVNetNameAddressPrefix"></a> [hubVNetNameAddressPrefix](#input\_hubVNetNameAddressPrefix) | CIDR prefix to use for Hub VNet | `string` | `"10.0.0.0/16"` | no |
| <a name="input_jumpBoxAddressPrefix"></a> [jumpBoxAddressPrefix](#input\_jumpBoxAddressPrefix) | CIDR prefix to use for Jumpbox VNet | `string` | `"10.0.3.0/24"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure location where all resources should be created | `string` | `"westus2"` | no |
| <a name="input_numberOfWorkers"></a> [numberOfWorkers](#input\_numberOfWorkers) | numberOfWorkers for ASE | `number` | `3` | no |
| <a name="input_spokeVNetNameAddressPrefix"></a> [spokeVNetNameAddressPrefix](#input\_spokeVNetNameAddressPrefix) | CIDR prefix to use for Spoke VNet | `string` | `"10.1.0.0/16"` | no |
| <a name="input_workerPool"></a> [workerPool](#input\_workerPool) | workerPool for ASE | `number` | `1` | no |
| <a name="input_workloadName"></a> [workloadName](#input\_workloadName) | A short name for the workload being deployed | `string` | `"ase"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_CICDAgentSubnetId"></a> [CICDAgentSubnetId](#output\_CICDAgentSubnetId) | n/a |
| <a name="output_CICDAgentSubnetName"></a> [CICDAgentSubnetName](#output\_CICDAgentSubnetName) | n/a |
| <a name="output_appServicePlanId"></a> [appServicePlanId](#output\_appServicePlanId) | n/a |
| <a name="output_appServicePlanName"></a> [appServicePlanName](#output\_appServicePlanName) | n/a |
| <a name="output_aseId"></a> [aseId](#output\_aseId) | n/a |
| <a name="output_aseName"></a> [aseName](#output\_aseName) | Output section |
| <a name="output_aseSubnetId"></a> [aseSubnetId](#output\_aseSubnetId) | n/a |
| <a name="output_aseSubnetName"></a> [aseSubnetName](#output\_aseSubnetName) | n/a |
| <a name="output_bastionSubnetId"></a> [bastionSubnetId](#output\_bastionSubnetId) | n/a |
| <a name="output_bastionSubnetName"></a> [bastionSubnetName](#output\_bastionSubnetName) | n/a |
| <a name="output_hubVNetId"></a> [hubVNetId](#output\_hubVNetId) | n/a |
| <a name="output_hubVNetName"></a> [hubVNetName](#output\_hubVNetName) | Output section |
| <a name="output_jumpBoxSubnetId"></a> [jumpBoxSubnetId](#output\_jumpBoxSubnetId) | n/a |
| <a name="output_jumpBoxSubnetName"></a> [jumpBoxSubnetName](#output\_jumpBoxSubnetName) | n/a |
| <a name="output_spokeVNetId"></a> [spokeVNetId](#output\_spokeVNetId) | n/a |
| <a name="output_spokeVNetName"></a> [spokeVNetName](#output\_spokeVNetName) | n/a |
