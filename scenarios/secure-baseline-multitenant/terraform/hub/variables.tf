
variable "application_name" {
  type        = string
  description = "[Required] The name of your application"
  default     = "sec-baseline-1-hub"
}

variable "environment" {
  type        = string
  description = "[Required] The environment (dev, qa, staging, prod)"
}

variable "location" {
  type        = string
  description = "[Required] The Azure region where all resources in this example should be created"
}

variable "owner" {
  type        = string
  description = "[Required] Email or unique ID of the owner(s) for this deployment"
}

# variable "tenant_id" {
#   type        = string
#   description = "[Required] The Azure AD tenant ID for the identities"
# }

variable "tags" {
  type        = map(string)
  description = "[Optional] Additional tags to assign to your resources"
  default     = {}
}

variable "global_settings" {
  description = "[Optional] Global settings to configure each module with the appropriate naming standards."
  default     = {}
}

#####################################
# Hub Network Configuration Variables
#####################################
variable "bastion_subnet_name" {
  type        = string
  description = "[Optional] Name of the subnet to deploy bastion resource to. Defaults to 'AzureBastionSubnet'"
  default     = "AzureBastionSubnet"
}

variable "firewall_subnet_name" {
  type        = string
  description = "[Optional] Name of the subnet for firewall resources. Defaults to 'AzureFirewallSubnet'"
  default     = "AzureFirewallSubnet"
}
variable "hub_vnet_cidr" {
  type        = list(string)
  description = "[Optional] The CIDR block(s) for the hub virtual network. Defaults to 10.242.0.0/20"
  default     = ["10.242.0.0/20"]
}

variable "firewall_subnet_cidr" {
  type        = list(string)
  description = "[Optional] The CIDR block(s) for the firewall subnet. Defaults to 10.242.0.0/26"
  default     = ["10.242.0.0/26"]
}

variable "bastion_subnet_cidr" {
  type        = list(string)
  description = "[Optional] The CIDR block(s) for the bastion subnet. Defaults to 10.242.0.64/26"
  default     = ["10.242.0.64/26"]
}

variable "spoke_vnet_cidr" {
  type        = list(string)
  description = "[Optional] The CIDR block(s) for the virtual network for whitelisting on the firewall. Defaults to 10.240.0.0/20"
  default     = ["10.240.0.0/20"]
}

variable "devops_subnet_cidr" {
  type        = list(string)
  description = "[Optional] The CIDR block for the subnet. Defaults to 10.240.10.128/16"
  default     = ["10.240.10.128/26"]
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
