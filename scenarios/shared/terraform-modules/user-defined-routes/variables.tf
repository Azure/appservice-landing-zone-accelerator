variable "route_table_name" {
  type        = string
  description = "The name of your route table"
}

variable "resource_group" {
  type        = string
  description = "The name of the resource group where all resources in this module will be created."
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example will be created"
}

variable "routes" {
  type = list(object(
    {
      name                   = string,
      address_prefix         = string,
      next_hop_type          = string,
      next_hop_in_ip_address = string
    }
  ))

  description = "The list of routes to create."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of subnets to create routes for."
}

variable "global_settings" {
  description = "Global settings for the naming convention module."
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}