variable "application_name" {
  type        = string
  description = "The name of your application"
}

variable "unique_id" {
  type        = string
  description = "A unique identifier"
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

variable "tenant_id" {
  type        = string
  description = "The tenant id where the resources will be created"
}

variable "web_app_principal_id" {
    type        = string
    description = "The identity principal id of the web app"
}

variable "web_app_slot_principal_id" {
    type        = string
    description = "The identity principal id of the web app slot"
}

variable "private_dns_zone_name" {
  type        = string
  description = "The private dns zone name where the app config service will be integrated"
}

variable "private_link_subnet_id" {
  type        = string
  description = "The subnet id where the private link will be integrated"
}

variable "sql_server_name" {
  type        = string
  description = "The name of the SQL server"
}

variable "sql_db_name" {
  type        = string
  description = "The name of the SQL database"
}