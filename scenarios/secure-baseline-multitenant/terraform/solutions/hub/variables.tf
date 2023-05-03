variable "application_name" {
  type        = string
  description = "The name of your application"
  default     = "secure-baseline"
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
  default     = "westeurope"
}

variable "location_short" {
  type        = string
  description = "The short name for the Azure region where all resources in this example should be created"
  default     = "weu"
}

variable "hub_vnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the hub virtual network."
  default     = null
}

variable "firewall_subnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the firewall subnet."
  default     = null
}

variable "bastion_subnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the bastion subnet."
  default     = null
}

variable "spoke_vnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the virtual network."
  default     = null
}

variable "appsvc_subnet_cidr" {
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

variable "deployment_options" {
  type = object({
    enable_waf                 = bool
    enable_egress_lockdown     = bool
    enable_diagnostic_settings = bool
    deploy_bastion             = bool
    deploy_redis               = bool
    deploy_sql_database        = bool
    deploy_app_config          = bool
    deploy_vm                  = bool
  })

  description = "Opt-in settings for the deployment: enable WAF in Front Door, deploy Azure Firewall and UDRs in the spoke network to force outbound traffic to the Azure Firewall, deploy Redis Cache."

  default = {
    enable_waf                 = true
    enable_egress_lockdown     = true
    enable_diagnostic_settings = true
    deploy_bastion             = true
    deploy_redis               = true
    deploy_sql_database        = true
    deploy_app_config          = true
    deploy_vm                  = true
  }
}
