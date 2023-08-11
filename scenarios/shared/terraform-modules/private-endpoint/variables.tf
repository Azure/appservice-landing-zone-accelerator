variable "name" {
  type        = string
  description = "The name of the private endpoint"
}

variable "resource_group" {
  type        = string
  description = "The name of the resource group where the private endpoint will be created"
}

variable "location" {
  type        = string
  description = "The location of the resource group where the private endpoint will be created"
}

variable "subnet_id" {
  type        = string
  description = "The id of the subnet where the private endpoint will be created"
}

variable "private_connection_resource_id" {
  type        = string
  description = "The id of the resource to which the private endpoint will be connected"
}

variable "subresource_names" {
  type        = list(string)
  description = "The subresource names of the resource to which the private endpoint will be connected"
}

variable "private_dns_records" {
  type        = list(string)
  description = "The dns records to be created for the private endpoint"
}

variable "private_dns_zone" {
  type = object({
    id                  = string
    name                = string
    resource_group_name = string
  })

  description = "The private dns zone id where the app service will be integrated"
}

variable "ttl" {
  type        = number
  description = "The time to live of the dns records"
  default     = 300
}