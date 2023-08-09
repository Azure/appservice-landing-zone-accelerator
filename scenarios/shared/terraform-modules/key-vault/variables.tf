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

variable "tenant_id" {
  type        = string
  description = "The Azure AD tenant ID for the identities. If no value provided, will use current deployment environment tenant."
  default     = null
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
  description = "The sku name for the app service plan"
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "Please, choose among one of the following SKUs for production workloads: standard, premium."
  }
}

variable "secret_reader_identities" {
  type        = list(string)
  description = "The list of identities that will be granted secret reader permissions"
}

variable "secret_officer_identities" {
  type        = list(string)
  description = "The list of identities that will be granted secret officer permissions"
  default     = []
}

variable "private_dns_zone" {
  type = object({
    id                  = string
    name                = string
    resource_group_name = string
  })

  description = "The private dns zone id where the app service will be integrated"
}

variable "global_settings" {
  description = "Global settings for the naming convention module."
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}