variable "application_name" {
  type        = string
  description = "The name of your application"
}

variable "unique_id" {
  type        = string
  description = "A unique identifier"
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
  description = "The tenant id where the resources will be created"
}

variable "aad_admin_group_object_id" {
  type = string
}

variable "aad_admin_group_name" {
  type = string
}

variable "private_link_subnet_id" {
  type        = string
  description = "The subnet id where the SQL database will be integrated"
}

variable "sql_databases" {
  type = list(object({
    name     = string
    sku_name = string
  }))

  description = "The list of SQL databases to be created"
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