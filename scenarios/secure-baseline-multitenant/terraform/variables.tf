variable "application_name" {
  type        = string
  description = "The name of your application"
  default     = "secure-baseline"
}

variable "resource_group" {
  type        = string
  description = "The name of the resource group where all resources in this example should be created."
  default     = "app-svc-secure-baseline-rg"
}

variable "environment" {
  type        = string
  description = "The environment (dev, test, prod...)"
  default     = "staging"
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
  default     = "westeurope"
}
