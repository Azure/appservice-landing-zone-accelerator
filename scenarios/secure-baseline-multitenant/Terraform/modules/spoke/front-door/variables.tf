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
  default     = "westeurope"
}

variable "unique_id" {
  type        = string
  description = "A unique identifier"
}

variable "azure_frontdoor_sku" {
  type = string
  default = "Premium_AzureFrontDoor"
}

variable "web_app_id" {
  type = string
  description = "The web app id"  
}

variable "web_app_hostname" {
  type = string
  description = "The web app hostname"  
}

variable "enable_waf" {
  type        = bool
  description = "Enable WAF in Azure Front Door"
  default     = true 
}