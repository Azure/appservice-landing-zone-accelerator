variable "resource_group" {
  type        = string
  description = "The name of the resource group where the private DNS zones will be created."
}

variable "name" {
  type        = string
  description = "The name of the private DNS zone."
}

variable "vnet_links" {
  type = list(object({
    vnet_id             = string
    vnet_resource_group = string
  }))

  description = "A list of virtual networks to link to the DNS zone."
}