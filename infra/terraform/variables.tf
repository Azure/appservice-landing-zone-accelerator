# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "location" {
  type        = string
  description = "Azure region for all resources (e.g. uksouth, eastus2)."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to create (e.g. rg-contoso-prod). The module creates this resource group automatically."
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9_().-]{1,89}[a-zA-Z0-9_()-]$", var.resource_group_name))
    error_message = "Must be a valid Azure resource group name (1-90 chars, alphanumerics/underscores/parentheses/hyphens/periods, cannot end in a period)."
  }
}

# -----------------------------------------------------------------------------
# App Service Plan
# -----------------------------------------------------------------------------

variable "app_service_plan_os_type" {
  type        = string
  default     = "Linux"
  description = "OS type for the App Service Plan. Valid values: Linux, Windows, WindowsContainer, WindowsManagedInstance."
  nullable    = false

  validation {
    condition     = contains(["Linux", "Windows", "WindowsContainer", "WindowsManagedInstance"], var.app_service_plan_os_type)
    error_message = "Must be one of: Linux, Windows, WindowsContainer, WindowsManagedInstance."
  }
}

variable "app_service_plan_sku_name" {
  type        = string
  default     = "P1v3"
  description = "SKU name for the App Service Plan (e.g. P1v3 for Premium v3, S1 for Standard). See module docs for the full list."
  nullable    = false
}

# -----------------------------------------------------------------------------
# Web Apps
# -----------------------------------------------------------------------------

variable "web_apps" {
  type        = any
  default     = {}
  description = <<-EOT
    Map of web apps to deploy. Each key is a logical name; values configure
    the app (site_config, app_settings, deployment_slots, etc.).
    See the AVM pattern module documentation for the full schema.
  EOT
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------

variable "virtual_network_address_space" {
  type        = set(string)
  default     = ["10.0.0.0/16"]
  description = "Address space for the spoke virtual network."
}

variable "app_service_subnet_address_prefix" {
  type        = string
  default     = "10.0.0.0/24"
  description = "Address prefix for the App Service integration subnet."
}

variable "private_endpoint_subnet_address_prefix" {
  type        = string
  default     = "10.0.1.0/24"
  description = "Address prefix for the private endpoint subnet."
}

# -----------------------------------------------------------------------------
# Feature Toggles
# -----------------------------------------------------------------------------

variable "front_door_enabled" {
  type        = bool
  default     = true
  description = "Deploy Azure Front Door (Premium with WAF) for secure ingress."
}

variable "key_vault_enabled" {
  type        = bool
  default     = true
  description = "Deploy Azure Key Vault for secrets management."
}

variable "application_insights_enabled" {
  type        = bool
  default     = true
  description = "Deploy Application Insights for APM and diagnostics."
}

variable "private_dns_zones_enabled" {
  type        = bool
  default     = true
  description = "Create private DNS zones and link them to the VNet (privatelink.azurewebsites.net, etc.)."
}

variable "app_service_environment_enabled" {
  type        = bool
  default     = false
  description = "Deploy an App Service Environment v3 (ASE). When true, the App Service Plan SKU is automatically set to Isolated tier if not already."
}

variable "app_service_environment_subnet_address_prefix" {
  type        = string
  default     = "10.0.2.0/24"
  description = "Address prefix for the App Service Environment subnet. Only used when app_service_environment_enabled is true."
}

variable "container_registry_enabled" {
  type        = bool
  default     = false
  description = "Deploy an Azure Container Registry (Premium SKU). Required for container-based web app deployments."
}

# -----------------------------------------------------------------------------
# ALZ Platform Landing Zone Integration (Optional)
#
# PREREQUISITE: These settings assume your Azure environment is managed by the
# ALZ Platform Landing Zone (https://aka.ms/alz/acc). The Platform Landing Zone
# provides hub networking (hub VNet, firewall/NVA), centralized private DNS
# zones, and diagnostic settings via Azure Policy (DINE).
#
# If you are NOT using an ALZ Platform Landing Zone, leave hub_virtual_network_id
# as null and the spoke will deploy standalone without hub peering or routing.
# -----------------------------------------------------------------------------

variable "hub_virtual_network_id" {
  type        = string
  default     = null
  description = "Resource ID of the hub VNet to peer with. When set, hub peering is enabled automatically."
}

variable "hub_firewall_private_ip" {
  type        = string
  default     = null
  description = "Private IP of the hub firewall or NVA (e.g. Azure Firewall). When set, a route table is created to route internet traffic (0.0.0.0/0) via the firewall."
}

variable "hub_route_table_address_spaces" {
  type        = list(string)
  default     = []
  description = "Additional address spaces to route through the hub firewall (e.g. the hub VNet CIDR). Only used when hub_firewall_private_ip is set."
}

variable "hub_route_table_resource_id" {
  type        = string
  default     = null
  description = "Resource ID of an existing route table to use instead of creating one. When set, takes precedence over hub_firewall_private_ip. Use this when the ALZ Platform Landing Zone provides a managed route table."
}

variable "alz_diagnostic_settings_mode_enabled" {
  type        = bool
  default     = false
  description = "When true, the module will NOT create diagnostic settings on resources. Enable this when your ALZ Platform Landing Zone uses DINE (Deploy If Not Exists) policies to manage diagnostic settings centrally."
}

variable "alz_private_dns_zone_mode_enabled" {
  type        = bool
  default     = false
  description = "When true, the module will NOT create private DNS zones. Enable this when your ALZ Platform Landing Zone manages private DNS zones centrally via Azure Policy."
}

# -----------------------------------------------------------------------------
# Metadata
# -----------------------------------------------------------------------------

variable "environment" {
  type        = string
  default     = "prod"
  description = "Environment name (e.g. dev, staging, prod). Used for tagging."
}

variable "tags" {
  type = map(string)
  default = {
    managed_by = "terraform"
    source     = "appservice-landing-zone-accelerator"
  }
  description = "Tags to apply to all resources. Defaults include managed_by and source."
}
