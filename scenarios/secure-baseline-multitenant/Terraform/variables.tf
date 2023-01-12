variable "application_name" {
  type        = string
  description = "The name of your application"
  default     = "secure-baseline"
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

variable "aad_admin_group_object_id" {
  type        = string
  description = "The object ID of the Azure AD group that should be granted SQL Admin permissions to the SQL Server"
}

variable "aad_admin_group_name" {
  type        = string
  description = "The name of the Azure AD group that should be granted SQL Admin permissions to the SQL Server"
}

variable "hub_vnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the hub virtual network."
  default     = null
}

variable "firewall_subnet_cidr" {
  type        = string
  description = "The CIDR block for the firewall subnet."
  default     = null
}

variable "bastion_subnet_cidr" {
  type        = string
  description = "The CIDR block for the bastion subnet."
  default     = null
}

variable "spoke_vnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the virtual network."
  default     = null
}

variable "appsvc_int_subnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the subnet."
  default     = null
}

variable "front_door_subnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the subnet."
  default     = null
}

variable "devops_subnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the subnet."
  default     = null
}

variable "private_link_subnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the subnet."
  default     = null
}

variable "vm_admin_username" {
  type        = string
  description = "The username for the local VM admin account. Prefer using the Azure AD admin account."
  default     = null
}

variable "vm_admin_password" {
  type        = string
  description = "The password for the local VM admin account. Prefer using the Azure AD admin account."
  default     = null
}

variable "vm_aad_admin_username" {
  type        = string
  description = "The Azure AD username for the VM admin account."
}

variable "enable_waf" {
  type        = bool
  description = "Enable WAF in Azure Front Door"
  default     = true
}

variable "enable_egress_lockdown" {
  type        = bool
  description = "Deploy Azure Firewall and UDRs in the spoke network to force outbound traffic to the Azure Firewall"
  default     = true
}