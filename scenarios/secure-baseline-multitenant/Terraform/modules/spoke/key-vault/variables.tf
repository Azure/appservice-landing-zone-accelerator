variable "application_name" {
  type        = string
  description = "The name of your application"
  default     = "app-svc-lz-4254"
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

variable "app_svc_integration_subnet_id" {
  type        = string
  description = "The subnet id where the app service will be integrated"
}

variable "app_svc_managed_id" {
  type        = string
  description = "The system assigned managed identity that will be assigned with KV policy"
}

variable "sku_name" {
  type        = string
  description = "The sku name for the app service plan"
  default     = "standard"
  validation {
    condition = contains(["standard", "premium"], var.sku_name)
    error_message = "Please, choose among one of the following SKUs for production workloads: standard, premium"
  }
}