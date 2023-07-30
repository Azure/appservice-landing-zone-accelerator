variable "name" {
  type        = string
  description = "The name of the application."
}

variable "resource_group" {
  type        = string
  description = "The name of the resource group where all resources in this example should be created."
}

variable "location" {
  type        = string
  description = "The Azure Region where all resources in this example should be created."
}

variable "vnet_cidr" {
  type        = list(string)
  description = "The address space that is used by the virtual network."
}

variable "peering_vnet" {
  type = object({
    id             = string,
    name           = string,
    resource_group = string
  })
  description = "The virtual network to peer with."
  default     = null
}

variable "subnets" {
  type = list(object({
    name        = string,
    subnet_cidr = list(string),
    delegation = object({
      name = string,
      service_delegation = object({
        name    = string,
        actions = list(string)
      })
    })
  }))

  description = "A list of subnets inside the virtual network."
}

variable "global_settings" {
  description = "Global settings for the naming convention module."
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}