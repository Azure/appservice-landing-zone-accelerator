variable "workloadName" {
  description = "A short name for the workload being deployed"
  type        = string
  default     = "sec-baseline-sgl" # ase single tenant
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
  type        = string
  default     = "10.0.0.0/16"
}

variable "spokeVNetNameAddressPrefix" {
  description = "CIDR prefix to use for Spoke VNet"
  type        = string
  default     = "10.1.0.0/16"
}

variable "bastionAddressPrefix" {
  description = "CIDR prefix to use for Hub VNet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "CICDAgentNameAddressPrefix" {
  description = "CIDR prefix to use for Spoke VNet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "jumpBoxAddressPrefix" {
  description = "CIDR prefix to use for Jumpbox VNet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "aseAddressPrefix" {
  description = "CIDR prefix to use for ASE"
  type        = string
  default     = "10.1.1.0/24"
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

variable "vmadminUserName" {
  description = "admin username for the virtual machine (devops agent, jumpbox)"
  type        = string
  default     = "vmadmin"
}

variable "vmadminPassword" {
  description = "admin password for the virtual machine (devops agent, jumpbox). If none is provided, will be randomly generated and stored in the Key Vault"
  type        = string
  default     = null
}
