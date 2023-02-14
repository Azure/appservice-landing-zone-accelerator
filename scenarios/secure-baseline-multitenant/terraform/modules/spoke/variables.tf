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

variable "private_dns_zones" {
  type        = list(any)
  description = "The list of private DNS zones deployed in the hub. This is a dependency for deploying the VM."
}

variable "private_dns_zones_rg" {
  type        = string
  description = "The name of the resource group where the private DNS zones are deployed."
}

variable "deployment_options" {
  type = object({
    enable_waf             = bool
    enable_egress_lockdown = bool
    deploy_redis           = bool
    deploy_sql_database    = bool
    deploy_app_config      = bool
  })

  description = "Opt-in settings for the deployment"
}

variable "appsvc_options" {
  type = object({
    service_plan = object({
      os_type  = string
      sku_name = string
    })
    web_app = object({
      slots = list(string)

      application_stack = object({
        current_stack  = string
        dotnet_version = optional(string)
        java_version   = optional(string)
        php_version    = optional(string)
        node_version   = optional(string)
      })
    })
  })

  description = "The options for the app service"

  default = {
    service_plan = {
      os_type  = "Windows"
      sku_name = "S1"
    }
    web_app = {
      slots = []

      application_stack = {
        current_stack  = "dotnet"
        dotnet_version = "6.0"
      }
    }
  }

  validation {
    condition     = contains(["Windows", "Linux"], var.appsvc_options.service_plan.os_type)
    error_message = "Please, choose among one of the following operating systems: Windows or Linux."
  }

  validation {
    condition     = contains(["S1", "S2", "S3", "P1v2", "P2v2", "P3v2"], var.appsvc_options.service_plan.sku_name)
    error_message = "Please, choose among one of the following SKUs for production workloads: S1, S2, S3, P1v2, P2v2 or P3v2."
  }

  validation {
    condition     = contains(["dotnet", "dotnetcore", "java", "php", "python", "node"], var.appsvc_options.web_app.application_stack.current_stack)
    error_message = "Please, choose among one of the following stacks: dotnet, dotnetcore, java, php, python or node."
  }
}
