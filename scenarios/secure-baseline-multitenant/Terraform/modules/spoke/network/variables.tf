variable "application_name" {
  type        = string
  description = "The name of your application"
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

variable "vnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the virtual network."
}

variable "appsvc_int_subnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the subnet."
}

variable "front_door_subnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the subnet."
}

variable "devops_subnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the subnet."
}

variable "private_link_subnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the subnet."
}

variable "firewall_private_ip" {
  type        = string
  description = "The private IP address of the Azure Firewall"
  default     = null
}

variable "deployment_options" {
  type = object({
    enable_waf             = bool
    enable_egress_lockdown = bool
    deploy_redis           = bool
  })

  description = "Opt-in settings for the deployment"
}
