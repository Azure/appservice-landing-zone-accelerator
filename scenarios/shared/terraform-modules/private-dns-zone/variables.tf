variable "resource_group" {
  type        = string
  description = "The name of the resource group where the private DNS zones will be created."
}

variable "dns_zone_name" {
  type        = string
  description = "The name of the private DNS zone."
}
# variable "dns_zones" {
#   type = list(string)

#   description = "A list of DNS zones to create."
# }

variable "dns_records" {
  type = list(object({
    dns_name = string
    records  = list(string)
  }))

  description = "A list of DNS records to create."
  default     = []
}

variable "vnet_links" {
  type = list(string)

  description = "A list of virtual networks to link to the DNS zone."
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "global_settings" {
  description = "Global settings for the naming convention module."
}