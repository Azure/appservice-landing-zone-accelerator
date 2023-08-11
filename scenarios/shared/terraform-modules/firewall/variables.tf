variable "resource_group" {
  type        = string
  description = "The name of the resource group where all resources in this example should be created."
}

variable "name" {
  type        = string
  description = "The name of the firewall."
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "The log analytics workspace id"
  default     = null
}

variable "firewall_rules_source_addresses" {
  type        = list(string)
  description = "The source addresses for the firewall rules."
}

variable "devops_subnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the subnet, which requires additional rules in the firewall."
}

variable "global_settings" {
  description = "Global settings for the naming convention module."
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}