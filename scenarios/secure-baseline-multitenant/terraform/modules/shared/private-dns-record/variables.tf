variable "resource_group" {
  type        = string
  description = "The name of the resource group where the private DNS zones will be created."
}

variable "dns_records" {
  type = list(object({
    dns_name = string
    zone_name = string
    private_ip_address = string
  }))

  description = "A list of DNS records to create."
}