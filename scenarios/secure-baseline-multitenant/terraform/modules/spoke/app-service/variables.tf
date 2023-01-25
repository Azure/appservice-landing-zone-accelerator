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

variable "sku_name" {
  type        = string
  description = "The sku name for the app service plan"
  default     = "S1"
  validation {
    condition     = contains(["S1", "S2", "S3", "P1v2", "P2v2", "P3v2"], var.sku_name)
    error_message = "Please, choose among one of the following SKUs for production workloads: S1, S2, S3, P1v2, P2v2 or P3v2"
  }
}

variable "os_type" {
  type        = string
  description = "The operating system for the app service plan"
  default     = "Windows"
  validation {
    condition     = contains(["Windows", "Linux"], var.os_type)
    error_message = "Please, choose among one of the following operating systems: Windows or Linux"
  }
}

variable "appsvc_subnet_id" {
  type        = string
  description = "The subnet id where the app service will be integrated"
}

variable "frontend_subnet_id" {
  type        = string
  description = "The subnet id where the front door will be integrated"
}

variable "private_dns_zone" {
  type = object({
    id   = string
    name = string
  })

  description = "The private dns zone id where the app service will be integrated"
}

variable "instrumentation_key" {
  type        = string
  description = "The instrumentation key for the app service"
}

variable "ai_connection_string" {
  type        = string
  description = "The connection string for applications insights"
}

variable "webapp_slot_name" {
  type        = string
  description = "The name of the app service slot"
}

