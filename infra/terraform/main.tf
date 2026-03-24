# -----------------------------------------------------------------------------
# App Service Landing Zone — AVM Pattern Module
#
# This configuration deploys a spoke-only App Service environment using the
# AVM pattern module. Hub networking is NOT deployed here — it is expected
# to be provided by the ALZ IaC Accelerator (https://aka.ms/alz/acc).
#
# The pattern module handles: App Service Plan, web app(s), VNet with
# private endpoints, Key Vault, Front Door, Application Insights,
# Log Analytics workspace, and private DNS zones — all in one call.
# -----------------------------------------------------------------------------

locals {
  # Enable ALZ hub peering when a hub VNet ID is provided
  hub_peering_enabled = var.hub_virtual_network_id != null

  # Enable a route table when a hub firewall IP is provided (unless an existing RT is supplied)
  route_table_enabled = var.hub_route_table_resource_id == null && var.hub_firewall_private_ip != null
}

module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.2"

  name             = var.resource_group_name
  location         = var.location
  tags             = var.tags
  enable_telemetry = true
}

module "app_service_landing_zone" {
  source  = "Azure/avm-ptn-app-service-landing-zone/azure"
  version = "0.1.0"

  # --- Required inputs ---
  location  = var.location
  parent_id = module.resource_group.resource_id

  # --- App Service Plan ---
  app_service_plan_os_type  = var.app_service_plan_os_type
  app_service_plan_sku_name = var.app_service_plan_sku_name

  # --- Web Apps ---
  web_apps = var.web_apps

  # --- Networking (spoke VNet) ---
  # The pattern module creates a spoke VNet with dedicated subnets for
  # App Service integration and private endpoints.
  virtual_network_address_space          = var.virtual_network_address_space
  app_service_subnet_address_prefix      = var.app_service_subnet_address_prefix
  private_endpoint_subnet_address_prefix = var.private_endpoint_subnet_address_prefix

  # --- App Service Environment (ASE v3) ---
  app_service_environment_enabled               = var.app_service_environment_enabled
  app_service_environment_subnet_address_prefix = var.app_service_environment_subnet_address_prefix

  # --- Container Registry ---
  container_registry_enabled = var.container_registry_enabled

  # --- Feature toggles ---
  front_door_enabled           = var.front_door_enabled
  key_vault_enabled            = var.key_vault_enabled
  application_insights_enabled = var.application_insights_enabled
  private_dns_zones_enabled    = var.private_dns_zones_enabled

  # --- ALZ Platform Landing Zone Integration (optional) ---
  # When hub_virtual_network_id is set, the spoke VNet peers to the hub.
  # When hub_firewall_private_ip is set, a UDR sends 0.0.0.0/0 via the firewall.
  # When alz_diagnostic_settings_mode_enabled is true, module skips diagnostic settings (ALZ DINE policy handles them).
  # When alz_private_dns_zone_mode_enabled is true, module skips private DNS zones (ALZ policy handles them).
  alz_platform_landing_zone_peer_to_hub_enabled            = local.hub_peering_enabled
  alz_platform_landing_zone_peering_hub_virtual_network_id = var.hub_virtual_network_id

  alz_platform_landing_zone_route_table_enabled                          = local.route_table_enabled
  alz_platform_landing_zone_route_table_hub_virtual_appliance_ip_address = var.hub_firewall_private_ip
  alz_platform_landing_zone_route_table_address_spaces                   = var.hub_route_table_address_spaces
  alz_platform_landing_zone_route_table_resource_id                      = var.hub_route_table_resource_id

  alz_platform_landing_zone_diagnostic_settings_mode_enabled = var.alz_diagnostic_settings_mode_enabled
  alz_platform_landing_zone_private_dns_zone_mode_enabled    = var.alz_private_dns_zone_mode_enabled

  # --- Observability ---
  # The module creates a Log Analytics workspace by default when
  # application_insights_enabled = true (via log_analytics_workspace_enabled default).

  # --- Tags ---
  tags = var.tags

  # --- Telemetry ---
  # AVM collects anonymous telemetry to improve module quality.
  # Set to false to opt out: https://aka.ms/avm/telemetryinfo
  enable_telemetry = true
}
