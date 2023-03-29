
locals {
  # TODO: delegate naming convention to the azurecaf-name terraform module
  aseName            = substr("ase-${local.resourceSuffix}", 0, 37)
  appServicePlanName = "asp-${local.resourceSuffix}"
  privateDnsZoneName = "${local.aseName}.appserviceenvironment.net"

  create_new_ase                    = var.app_service_environment_name == null || var.app_service_environment_resource_group_name == null ? true : false
  ase                               = local.create_new_ase ? azurerm_app_service_environment_v3.ase[0] : data.azurerm_app_service_environment_v3.existing[0]
  ase_internal_inbound_ip_addresses = local.create_new_ase ? azurerm_app_service_environment_v3.ase[0].internal_inbound_ip_addresses : data.azurerm_app_service_environment_v3.existing[0].internal_inbound_ip_addresses
}

data "azurerm_app_service_environment_v3" "existing" {
  count               = local.create_new_ase ? 0 : 1
  name                = var.app_service_environment_name
  resource_group_name = var.app_service_environment_resource_group_name
}

resource "azurerm_app_service_environment_v3" "ase" {
  count = local.create_new_ase ? 1 : 0

  name                         = local.aseName
  resource_group_name          = azurerm_resource_group.aserg.name
  subnet_id                    = azurerm_subnet.vnetSpokeSubnet.id
  internal_load_balancing_mode = "Web, Publishing"
  zone_redundant               = true
}

resource "azurerm_service_plan" "appServicePlan" {
  name                       = local.appServicePlanName
  location                   = azurerm_resource_group.aserg.location
  resource_group_name        = azurerm_resource_group.aserg.name
  app_service_environment_id = local.ase.id
  per_site_scaling_enabled   = false
  zone_balancing_enabled     = true

  os_type      = "Windows"
  sku_name     = "I${var.workerPool}v2"
  worker_count = var.numberOfWorkers

}

resource "azurerm_private_dns_zone" "privateDnsZone" {
  name                = local.privateDnsZoneName
  resource_group_name = azurerm_resource_group.aserg.name
  # depends_on          = [azurerm_app_service_environment_v3.ase]
}

resource "azurerm_private_dns_zone_virtual_network_link" "privateDnsZoneName_vnetLink" {
  name                  = "vnetLink"
  resource_group_name   = azurerm_resource_group.aserg.name
  private_dns_zone_name = azurerm_private_dns_zone.privateDnsZone.name
  virtual_network_id    = azurerm_virtual_network.vnetSpoke.id
  registration_enabled  = false
}

// TODO: refactor records to allow for multiple records via input parameters
resource "azurerm_private_dns_a_record" "privateDnsZoneName_all" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.privateDnsZone.name
  resource_group_name = azurerm_resource_group.aserg.name
  ttl                 = 3600
  records             = local.ase.internal_inbound_ip_addresses
}

resource "azurerm_private_dns_a_record" "privateDnsZoneName_scm" {
  name                = "*.scm"
  zone_name           = azurerm_private_dns_zone.privateDnsZone.name
  resource_group_name = azurerm_resource_group.aserg.name
  ttl                 = 3600
  records             = local.ase.internal_inbound_ip_addresses
}

resource "azurerm_private_dns_a_record" "privateDnsZoneName_Amp" {
  name                = "@"
  zone_name           = azurerm_private_dns_zone.privateDnsZone.name
  resource_group_name = azurerm_resource_group.aserg.name
  ttl                 = 3600
  records             = local.ase.internal_inbound_ip_addresses
}

