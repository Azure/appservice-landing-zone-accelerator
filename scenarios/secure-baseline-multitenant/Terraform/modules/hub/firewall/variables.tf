variable "resource_group" {
  type        = string
  description = "The name of the resource group where all resources in this example should be created."
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
  default     = "westeurope"
}

variable "hub_vnet_id" {
  type        = string
  description = "The ID of the hub virtual network."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "The log analytics workspace id"
}