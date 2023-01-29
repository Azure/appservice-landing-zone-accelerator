variable "application_name" {
  type        = string
  description = "The name of your application"
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

variable "vm_admin_username" {
  type        = string
  description = "The username for the VM admin account."
}

variable "vm_admin_password" {
  type        = string
  description = "The password for the VM admin account."
}

variable "vm_aad_admin_username" {
  type        = string
  description = "The Azure AD username for the VM admin account."
}

variable "firewall_private_ip" {
  type        = string
  description = "The private IP address of the Azure Firewall (needed to setup UDRs)"
}

variable "firewall_rules" {
  type        = map(any)
  description = "The list of firewall rules deployed in the Azure Firewall. This is a dependency for deploying the VM."
}

variable "webapp_slot_name" {
  type        = string
  description = "The name of the app service slot"
}

variable "deployment_options" {
  type = object({
    enable_waf             = bool
    enable_egress_lockdown = bool
    deploy_redis           = bool
  })

  description = "Opt-in settings for the deployment"
}
