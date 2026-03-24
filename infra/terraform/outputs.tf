# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

# --- App Service Plan ---

output "app_service_plan_id" {
  description = "Resource ID of the App Service Plan."
  value       = module.app_service_landing_zone.app_service_plan_id
}

# --- Web Apps ---

output "web_apps" {
  description = "Map of deployed web app resources, keyed by the web_apps input key."
  value       = module.app_service_landing_zone.web_apps
}

output "web_app_default_hostnames" {
  description = "Default hostnames for each web app."
  value = {
    for key, app in module.app_service_landing_zone.web_apps : key => "https://${app.resource.default_hostname}"
  }
}

# --- Networking ---

output "virtual_network_id" {
  description = "Resource ID of the spoke virtual network."
  value       = module.app_service_landing_zone.virtual_network_id
}

output "virtual_network_name" {
  description = "Name of the spoke virtual network."
  value       = module.app_service_landing_zone.virtual_network_name
}

# --- Front Door ---

output "front_door" {
  description = "Azure Front Door resource output (null if disabled)."
  value       = module.app_service_landing_zone.front_door
}

# --- Key Vault ---

output "key_vault_id" {
  description = "Resource ID of the Key Vault (null if disabled)."
  value       = module.app_service_landing_zone.key_vault_id
}

output "key_vault_name" {
  description = "Name of the Key Vault (null if disabled)."
  value       = module.app_service_landing_zone.key_vault_name
}

# --- Application Insights ---

output "application_insights_connection_string" {
  description = "Application Insights connection string."
  sensitive   = true
  value       = module.app_service_landing_zone.application_insights_connection_string
}

# --- Log Analytics ---

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = module.app_service_landing_zone.log_analytics_workspace_id
}

# --- Resource Group ---

output "resource_group_id" {
  description = "Resource ID of the resource group."
  value       = module.resource_group.resource_id
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = module.resource_group.name
}
