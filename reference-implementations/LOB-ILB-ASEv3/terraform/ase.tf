
locals {
  // Variables
  vnetId             = azurerm_virtual_network.vnetSpoke.id
  aseSubnetId        = "${azurerm_virtual_network.vnetSpoke.id}/subnets/${local.aseSubnetName}"
  numberOfWorkers    = var.numberOfWorkers
  workerPool         = var.workerPool
  aseName            = substr("ase-${local.resourceSuffix}", 0, 37)
  appServicePlanName = "asp-${local.resourceSuffix}"
  privateDnsZoneName = "${local.aseName}.appserviceenvironment.net"
}

resource "azurerm_app_service_environment_v3" "ase" {
  name                         = local.aseName
  resource_group_name          = azurerm_resource_group.aserg.name
  subnet_id                    = local.aseSubnetId
  internal_load_balancing_mode = "Web, Publishing"
  zone_redundant               = true
  depends_on                   = [azurerm_bastion_host.bastionHost]
}

resource "azurerm_service_plan" "appServicePlan" {
  name                       = local.appServicePlanName
  location                   = azurerm_resource_group.aserg.location
  resource_group_name        = azurerm_resource_group.aserg.name
  app_service_environment_id = azurerm_app_service_environment_v3.ase.id
  per_site_scaling_enabled   = false
  zone_balancing_enabled     = true

  os_type = "Windows"
  sku_name     = "I${local.workerPool}v2"
  worker_count = local.numberOfWorkers

  depends_on = [azurerm_bastion_host.bastionHost]
}

resource "azurerm_private_dns_zone" "privateDnsZone" {
  name                = local.privateDnsZoneName
  resource_group_name = azurerm_resource_group.aserg.name
  depends_on          = [azurerm_app_service_environment_v3.ase]
}

resource "azurerm_private_dns_zone_virtual_network_link" "privateDnsZoneName_vnetLink" {
  name                  = "vnetLink"
  resource_group_name   = azurerm_resource_group.aserg.name
  private_dns_zone_name = local.privateDnsZoneName
  virtual_network_id    = local.vnetId
  registration_enabled  = false
  depends_on            = [azurerm_app_service_environment_v3.ase, azurerm_private_dns_zone.privateDnsZone]
}

resource "azurerm_private_dns_a_record" "privateDnsZoneName_all" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.privateDnsZone.name
  resource_group_name = azurerm_resource_group.aserg.name
  ttl                 = 3600
  records             = azurerm_app_service_environment_v3.ase.internal_inbound_ip_addresses
  depends_on          = [azurerm_private_dns_zone.privateDnsZone]
}

resource "azurerm_private_dns_a_record" "privateDnsZoneName_scm" {
  name                = "*.scm"
  zone_name           = azurerm_private_dns_zone.privateDnsZone.name
  resource_group_name = azurerm_resource_group.aserg.name
  ttl                 = 3600
  records             = azurerm_app_service_environment_v3.ase.internal_inbound_ip_addresses
  depends_on          = [azurerm_private_dns_zone.privateDnsZone]
}

resource "azurerm_private_dns_a_record" "privateDnsZoneName_Amp" {
  name                = "@"
  zone_name           = azurerm_private_dns_zone.privateDnsZone.name
  resource_group_name = azurerm_resource_group.aserg.name
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
  value = azurerm_service_plan.appServicePlan.name
}
output "appServicePlanId" {
  value = azurerm_service_plan.appServicePlan.id
}
