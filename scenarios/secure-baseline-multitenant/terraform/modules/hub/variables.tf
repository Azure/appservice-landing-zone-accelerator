variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
  default     = "westeurope"
}

variable "vnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the virtual network."
}

variable "firewall_subnet_cidr" {
  type        = string
  description = "The CIDR block for the firewall subnet."
}

variable "bastion_subnet_cidr" {
  type        = string
  description = "The CIDR block for the bastion subnet."
}

variable "deploy_firewall" {
  type    = bool
  default = false
}

variable "firewall_rules_source_addresses" {
  type        = list(string)
  description = "The source addresses for the firewall rules."
  default     = []
}

variable "devops_subnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the DevOps subnet, which requires additional rules in the firewall."
  default     = []
}
