variable "resource_group" {
  type        = string
  description = "The name of the resource group where all resources in this example should be created."
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
  default     = "westeurope"
}

variable "name" {
  type        = string
  description = "The name of the bastion host."
  default     = "bastion"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where the bastion host should be deployed."
}
