variable "application_name" {
  type        = string
  description = "The name of your application"
}

variable "resource_group" {
  type        = string
  description = "The name of the resource group where all resources in this example should be created."
}

variable "environment" {
  type        = string
  description = "The environment (dev, test, prod...)"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
  default     = "westus2"
}

variable "azure_frontdoor_sku" {
  type    = string
  default = "Premium_AzureFrontDoor"
}

variable "enable_waf" {
  type        = bool
  description = "Enable WAF in Azure Front Door"
  default     = true
}

variable "endpoint_settings" {
  type = list(object({
    endpoint_name            = string
    web_app_id               = string
    web_app_hostname         = string
    private_link_target_type = string
  }))

  description = "The name of the front door endpoint."
}

variable "unique_id" {
  type        = string
  description = "The unique id"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "The log analytics workspace id"
}

variable "enable_diagnostic_settings" {
  type        = bool
  description = "Enable diagnostic settings"
  default     = false
}

variable "global_settings" {
  description = "Global settings for the naming convention module."
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}