# =============================================================================
# App Service Plan — Linux Container Web App (no ASE)
#
# Deploys a Premium v3 Linux App Service Plan running a Docker container
# from Azure Container Registry. No ASE required.
#
# PREREQUISITE: This configuration expects an ALZ Platform Landing Zone
# (https://aka.ms/alz/acc) providing hub networking and connectivity.
# Update the hub_virtual_network_id and hub_firewall_private_ip below
# with values from your Platform Landing Zone deployment.
#
# Usage: cp examples/asp-linux-container.tfvars terraform.tfvars
# =============================================================================

# --- Required ---
location            = "uksouth"
resource_group_name = "rg-contoso-asp-linuxc-prod"

# --- App Service Plan ---
app_service_plan_os_type  = "Linux"
app_service_plan_sku_name = "P1v3"

# --- Web Apps ---
web_apps = {
  contoso-asp-linuxc-app = {
    site_config = {
      always_on = true
      application_stack = {
        docker = {
          docker_image_name   = "contoso/webapp:latest"
          docker_registry_url = "https://contosoasplinuxcacr.azurecr.io"
        }
      }
    }
    deployment_slots = {
      staging = {
        name = "staging"
        site_config = {
          application_stack = {
            docker = {
              docker_image_name   = "contoso/webapp:staging"
              docker_registry_url = "https://contosoasplinuxcacr.azurecr.io"
            }
          }
        }
      }
    }
  }
}

# --- Networking ---
virtual_network_address_space          = ["10.9.0.0/16"]
app_service_subnet_address_prefix      = "10.9.0.0/24"
private_endpoint_subnet_address_prefix = "10.9.1.0/24"

# --- Feature Toggles ---
front_door_enabled           = true
key_vault_enabled            = true
application_insights_enabled = true
private_dns_zones_enabled    = true

# --- ASE (not used) ---
app_service_environment_enabled = false

# --- Container Registry ---
container_registry_enabled = true

# --- ALZ Platform Landing Zone Integration ---
# Replace with values from your ALZ Platform Landing Zone deployment.
# See https://aka.ms/alz/acc for details on deploying the Platform Landing Zone.
hub_virtual_network_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-connectivity/providers/Microsoft.Network/virtualNetworks/vnet-hub-uksouth"
hub_firewall_private_ip        = "10.0.0.4"
hub_route_table_address_spaces = ["10.0.0.0/16"]
# hub_route_table_resource_id = null  # Uncomment to use an existing route table from your PLZ

# Set to true if your ALZ Platform Landing Zone uses DINE policies for diagnostics
alz_diagnostic_settings_mode_enabled = false

# Set to true if your ALZ Platform Landing Zone manages private DNS zones centrally
alz_private_dns_zone_mode_enabled = false

# --- Metadata ---
environment = "prod"
tags = {
  workload    = "contoso-asp-linux-container"
  environment = "prod"
  deployed_by = "terraform"
  owner       = "platform-team"
}
