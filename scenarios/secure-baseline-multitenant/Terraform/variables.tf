variable "application_name" {
  type        = string
  description = "The name of your application"
  default     = "secure-baseline-h20221208"
}

variable "resource_group" {
  type        = string
  description = "The name of the resource group where all resources in this example should be created."
  default     = "app-svc-secure-baseline-rg"
}

variable "environment" {
  type        = string
  description = "The environment (dev, qa, staging, prod)"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
  default     = "westeurope"
}

variable "tenant_id" {
  type        = string
  description = "The Azure AD tenant ID for the identities"
}

variable "sql_admin_group_object_id" {
  type        = string
  description = "The object ID of the Azure AD group that should be granted SQL Admin permissions to the SQL Server"
}

variable "sql_admin_group_name" {
  type        = string
  description = "The name of the Azure AD group that should be granted SQL Admin permissions to the SQL Server"
}