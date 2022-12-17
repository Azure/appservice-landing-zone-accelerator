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