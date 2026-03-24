# =============================================================================
# ASE v3 — Windows Container Web App
#
# Deploys an App Service Environment v3 with a WindowsContainer App Service
# Plan running a Docker container from Azure Container Registry.
#
# PREREQUISITE: This configuration expects an ALZ Platform Landing Zone
# (https://aka.ms/alz/acc) providing hub networking and connectivity.
# Update the hub_virtual_network_id and hub_firewall_private_ip below
# with values from your Platform Landing Zone deployment.
#
# Usage: cp examples/ase-windows-container.tfvars terraform.tfvars
# =============================================================================

# --- Required ---
location            = "uksouth"
resource_group_name = "rg-contoso-ase-winc-prod"

# --- App Service Plan ---
app_service_plan_os_type  = "WindowsContainer"
app_service_plan_sku_name = "I1v2"

# --- Web Apps ---
web_apps = {
  contoso-ase-winc-app = {
    site_config = {
      always_on = true
      application_stack = {
        docker = {
          docker_image_name   = "contoso/webapp:latest"
          docker_registry_url = "https://contosoasewincacr.azurecr.io"
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
              docker_registry_url = "https://contosoasewincacr.azurecr.io"
            }
          }
        }
      }
    }
  }
}

# --- Networking ---
virtual_network_address_space                 = ["10.3.0.0/16"]
app_service_subnet_address_prefix             = "10.3.0.0/24"
private_endpoint_subnet_address_prefix        = "10.3.1.0/24"
app_service_environment_subnet_address_prefix = "10.3.2.0/24"

# --- Feature Toggles ---
front_door_enabled           = true
key_vault_enabled            = true
application_insights_enabled = true
private_dns_zones_enabled    = true

# --- ASE v3 ---
app_service_environment_enabled = true

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
  workload    = "contoso-ase-windows-container"
  environment = "prod"
  deployed_by = "terraform"
  owner       = "platform-team"
}
