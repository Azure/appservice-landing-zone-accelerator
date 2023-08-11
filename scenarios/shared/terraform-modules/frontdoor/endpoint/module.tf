resource "null_resource" "web_app" {
  triggers = {
    web_app_hostname         = var.web_app_hostname,
    web_app_id               = var.web_app_id,
    private_link_target_type = var.private_link_target_type
  }
}

resource "azurerm_cdn_frontdoor_endpoint" "web_app" {
  name                     = var.endpoint_name
  cdn_frontdoor_profile_id = var.frontdoor_profile_id

  lifecycle {
    replace_triggered_by = [
      null_resource.web_app
    ]
  }
}

resource "azurerm_cdn_frontdoor_origin_group" "web_app" {
  name                     = var.endpoint_name
  cdn_frontdoor_profile_id = var.frontdoor_profile_id
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

  lifecycle {
    replace_triggered_by = [
      null_resource.web_app
    ]
  }
}

resource "azurerm_cdn_frontdoor_origin" "web_app" {

  name                           = var.endpoint_name
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.web_app.id
  enabled                        = true
  host_name                      = var.web_app_hostname
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.web_app_hostname
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true

  private_link {
    request_message        = "Request access for CDN Frontdoor Private Link Origin to Web App 2"
    target_type            = var.private_link_target_type
    location               = var.location
    private_link_target_id = var.web_app_id
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.web_app
    ]
  }
}

resource "azurerm_cdn_frontdoor_route" "web_app" {
  name                          = var.endpoint_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.web_app.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.web_app.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.web_app.id]
  supported_protocols           = ["Http", "Https"]
  patterns_to_match             = ["/*"]
  forwarding_protocol           = "HttpsOnly"
  link_to_default_domain        = true
  https_redirect_enabled        = true

  lifecycle {
    replace_triggered_by = [
      null_resource.web_app
    ]
  }
}