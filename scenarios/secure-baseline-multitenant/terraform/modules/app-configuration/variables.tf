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
  default     = "westeurope"
}

variable "tenant_id" {
  type        = string
  description = "The tenant id where the resources will be created"
}

variable "data_reader_identities" {
  type        = list(string)
  description = "The list of identities that will be granted data reader permissions"
}

variable "data_owner_identities" {
  type        = list(string)
  description = "The list of identities that will be granted data owner permissions"
  default     = []
}

variable "private_dns_zone" {
  type = object({
    id             = string
    name           = string
    resource_group = string
  })

  description = "The private dns zone id where the app service will be integrated"
}

variable "private_link_subnet_id" {
  type        = string
  description = "The subnet id where the private link will be integrated"
}
