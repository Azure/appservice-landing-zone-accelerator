
locals {
  // Variables
  vnetId          = azurerm_virtual_network.vnetSpoke.id
  aseSubnetId     = "${azurerm_virtual_network.vnetSpoke.id}/subnets/${local.aseSubnetName}"
  numberOfWorkers = var.numberOfWorkers
  workerPool      = var.workerPool
  aseName         = substr("ase-${local.resourceSuffix}",0, 37)
  appServicePlanName = "asp-${local.resourceSuffix}"
  privateDnsZoneName = "${local.aseName}.appserviceenvironment.net"
}

resource "azurerm_app_service_environment_v3" "ase" {
  name                         = local.aseName
  resource_group_name          = local.aseResourceGroupName
  subnet_id                    = local.aseSubnetId
  internal_load_balancing_mode = "Web, Publishing"
  zone_redundant               = true
  depends_on = [azurerm_bastion_host.bastionHost]
}

resource "azurerm_app_service_plan" "appServicePlan" {
  name                = local.appServicePlanName
  location            = var.location
  resource_group_name = local.aseResourceGroupName
  app_service_environment_id = azurerm_app_service_environment_v3.ase.id
  is_xenon            = false
  per_site_scaling    = false
  reserved            = false
  zone_redundant      = true
  sku {
    tier = "IsolatedV2"
    size = "I${local.workerPool}v2"
    capacity = local.numberOfWorkers
  }
  depends_on = [azurerm_bastion_host.bastionHost]
}

resource "azurerm_private_dns_zone" "privateDnsZone" {
  name                = local.privateDnsZoneName
  resource_group_name = local.aseResourceGroupName
  depends_on = [azurerm_app_service_environment_v3.ase]
}

resource "azurerm_private_dns_zone_virtual_network_link" "privateDnsZoneName_vnetLink" {
  name                  = "vnetLink"
  resource_group_name   = local.aseResourceGroupName
  private_dns_zone_name = local.privateDnsZoneName
  virtual_network_id    = local.vnetId
  registration_enabled  = false
  depends_on = [azurerm_app_service_environment_v3.ase,azurerm_private_dns_zone.privateDnsZone]
}

resource "azurerm_private_dns_a_record" "privateDnsZoneName_all" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.privateDnsZone.name
  resource_group_name = local.aseResourceGroupName
  ttl                 = 3600
  records             = azurerm_app_service_environment_v3.ase.internal_inbound_ip_addresses
  depends_on          = [azurerm_private_dns_zone.privateDnsZone]
}

resource "azurerm_private_dns_a_record" "privateDnsZoneName_scm" {
  name                = "*.scm"
  zone_name           = azurerm_private_dns_zone.privateDnsZone.name
  resource_group_name = local.aseResourceGroupName
  ttl                 = 3600
  records             = azurerm_app_service_environment_v3.ase.internal_inbound_ip_addresses
  depends_on          = [azurerm_private_dns_zone.privateDnsZone]
}

resource "azurerm_private_dns_a_record" "privateDnsZoneName_Amp" {
  name                = "@"
  zone_name           = azurerm_private_dns_zone.privateDnsZone.name
  resource_group_name = local.aseResourceGroupName
  ttl                 = 3600
  records             = azurerm_app_service_environment_v3.ase.internal_inbound_ip_addresses
  depends_on          = [azurerm_private_dns_zone.privateDnsZone]
}

// Output section
output "aseName" {
  value = azurerm_app_service_environment_v3.ase.name
}
output "aseId" {
  value = azurerm_app_service_environment_v3.ase.id
}
output "appServicePlanName" {
  value = azurerm_app_service_plan.appServicePlan.name
}
output "appServicePlanId" {
  value = azurerm_app_service_plan.appServicePlan.id
}
