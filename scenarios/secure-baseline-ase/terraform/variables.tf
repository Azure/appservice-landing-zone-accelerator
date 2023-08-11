variable "owner" {
  type        = string
  description = "[Required] Email or unique ID of the owner(s) for this deployment"
}

variable "app_service_environment_name" {
  description = "[Optional] The NAME of an already existing App Service Environment to deploy the App Service Plan to."
  type        = string
  default     = null
}
variable "app_service_environment_resource_group_name" {
  description = "[Optional] The Resource Group NAME of an already existing App Service Environment to deploy the App Service Plan to. Will create a new ASE v3 if not provided."
  type        = string
  default     = null
}

variable "spoke_vnet_name" {
  description = "[Optional] The VNET NAME of an already existing spoke VNET."
  type        = string
  default     = null
}
variable "spoke_vnet_resource_group_name" {
  description = "[Optional] The Resource Group NAME of an already existing spoke VNET."
  type        = string
  default     = null
}

variable "private_dns_zone_name" {
  description = "[Optional] The NAME of an already existing Private DNS Zone to deploy the App Service Plan to."
  type        = string
  default     = null
}

variable "private_dns_zone_resource_group_name" {
  description = "[Optional] The Resource Group NAME of an already existing Private DNS Zone to deploy the App Service Plan to. Will create a new ASE v3 if not provided."
  type        = string
  default     = null
}

variable "application_name" {
  description = "A short name for the workload being deployed"
  type        = string
}

variable "environment" {
  description = "The environment for which the deployment is being executed"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The Azure location where all resources should be created"
  type        = string
  default     = "westus2"
}

variable "hubVNetNameAddressPrefix" {
  description = "CIDR prefix to use for Hub VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "spokeVNetNameAddressPrefix" {
  description = "CIDR prefix to use for Spoke VNet"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "bastionAddressPrefix" {
  description = "CIDR prefix to use for Hub VNet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "CICDAgentNameAddressPrefix" {
  description = "CIDR prefix to use for Spoke VNet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "jumpBoxAddressPrefix" {
  description = "CIDR prefix to use for Jumpbox VNet"
  type        = list(string)
  default     = ["10.0.3.0/24"]
}

variable "aseAddressPrefix" {
  description = "CIDR prefix to use for ASE"
  type        = list(string)
  default     = ["10.1.1.0/24"]
}

variable "numberOfWorkers" {
  description = "numberOfWorkers for ASE"
  type        = number
  default     = 3
}

variable "workerPool" {
  description = "workerPool for ASE"
  type        = number
  default     = 1
}

variable "vmAdminUsername" {
  description = "admin username for the virtual machine (devops agent, jumpbox)"
  type        = string
  default     = "vmadmin"
}

variable "vmAdminPassword" {
  description = "admin password for the virtual machine (devops agent, jumpbox). If none is provided, will be randomly generated and stored in the Key Vault"
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "[Optional] Additional tags to assign to your resources"
  default     = {}
}

variable "global_settings" {
  description = "[Optional] Global settings to configure each module with the appropriate naming standards."
  default     = {}
}

variable "deployment_options" {
  description = "[Optional] Deployment options to configure each module with the appropriate features."
  default     = {}

}

variable "vm_aad_admin_username" {
  type        = string
  description = "[Optional] The Azure AD username for the VM admin account. If vm_aad_admin_object_id is not specified, this value will be used."
  default     = null
}

variable "vm_aad_admin_object_id" {
  type        = string
  description = "The Azure AD username for the VM admin account. If vm_aad_admin_username is not specified, this value will be used."
  default     = null
}