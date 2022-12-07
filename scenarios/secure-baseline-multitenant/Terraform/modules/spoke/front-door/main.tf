terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.34.0"
    }
  }
}

resource "azurecaf_name" "frontdoor" {
  name          = var.application_name
  resource_type = "azurerm_cdn_frontdoor_profile"
  suffixes      = [var.environment]
}

data "azurerm_resource_group" "spoke-rg" {
  name = var.resource_group

}

locals {
  front_door_endpoint_name     = "afd-ep-${var.application_name}-${var.environment}"
  front_door_origin_group_name = "afd-og-${var.application_name}-${var.environment}"
  front_door_origin_name       = "afd-app-svc-${var.application_name}-${var.environment}"
  front_door_route_name        = "afd-route-${var.application_name}-${var.environment}"
}

resource "azurerm_cdn_frontdoor_profile" "frontdoor" {
  name                = azurecaf_name.frontdoor.result
  resource_group_name = var.resource_group
  sku_name            = var.azure_frontdoor_sku
}

resource "azurerm_cdn_frontdoor_endpoint" "web_app" {
  name                     = local.front_door_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id
}

resource "azurerm_cdn_frontdoor_origin_group" "web_app" {
  name                     = local.front_door_origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id
  session_affinity_enabled = false

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 16
    successful_samples_required        = 3
  }

  health_probe {
    path                = "/"
    request_type        = "HEAD"
    protocol            = "Https"
    interval_in_seconds = 100
  }
}

resource "azurerm_cdn_frontdoor_origin" "web_app" {
  name                          = local.front_door_origin_name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.web_app.id

  enabled                        = true
  host_name                      = var.web_app_hostname
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.web_app_hostname
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true

  private_link {
    request_message        = "Request access for CDN Frontdoor Private Link Origin to Web App"
    target_type            = "sites"
    location               = data.azurerm_resource_group.spoke-rg.location
    private_link_target_id = var.web_app_id
  }
}

resource "azurerm_cdn_frontdoor_route" "web_app" {
  name                          = local.front_door_route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.web_app.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.web_app.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.web_app.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true
}

resource "azurerm_cdn_frontdoor_firewall_policy" "waf" {
  name                = "WafMicrosoftDefaultRuleSet21"
  resource_group_name = var.resource_group
  sku_name            = azurerm_cdn_frontdoor_profile.frontdoor.sku_name
  mode                = "Prevention"
  enabled             = true

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "web-app-waf" {
  name                     = "WAF-Security-Policy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.waf.id

      association {
        patterns_to_match = ["/*"]
        domain {
          
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.web_app.id
        }
      }
    }
  }
}
