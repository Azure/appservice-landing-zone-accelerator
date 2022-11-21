
variable "application_name" {
  type        = string
  description = "The name of your application"
  default     = "app-svc-lz-4254"
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

variable "app-svc-integration-subnet-id" {
  type        = string
  description = "The subnet id where the app service will be integrated"
}

variable "front_door_integration_subnet_id" {
  type        = string
  description = "The subnet id where the front door will be integrated"
}

variable "private-dns-zone-id" {
  type        = string
  description = "The private dns zone id where the app service will be integrated"
}