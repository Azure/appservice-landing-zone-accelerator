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
  description = "The unique id"
}

variable "private_link_subnet_id" {
  type        = string
  description = "The subnet id"
}

variable "sku_name" {
  type        = string
  description = "The sku name for the redis-cache"
  default     = "standard"
  validation {
    condition = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "Please, choose among one of the following SKUs for production workloads: Basic, Standard, Premium."
  }
}

variable "private_dns_zone" {
  type = object({
    id             = string
    name           = string
    resource_group = string
  })

  description = "The private dns zone id where the app service will be integrated"
}