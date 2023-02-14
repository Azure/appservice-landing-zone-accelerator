variable "web_app_name" {
  type        = string
  description = "The name of the web application"
}

variable "service_plan_id" {
  type        = string
  description = "The id of the service plan where the web application will be created"
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

variable "unique_id" {
  type        = string
  description = "A unique identifier"
}

variable "service_plan_options" {
  type = object({
    os_type  = string
    sku_name = string
  })

  description = "The options for the app service"

  default = {
    os_type  = "Windows"
    sku_name = "S1"
  }

  validation {
    condition     = contains(["Windows", "Linux"], var.service_plan_options.os_type)
    error_message = "Please, choose among one of the following operating systems: Windows or Linux."
  }

  validation {
    condition     = contains(["S1", "S2", "S3", "P1v2", "P2v2", "P3v2"], var.service_plan_options.sku_name)
    error_message = "Please, choose among one of the following SKUs for production workloads: S1, S2, S3, P1v2, P2v2 or P3v2."
  }
}

variable "webapp_options" {
  type = object({
    instrumentation_key  = string
    ai_connection_string = string
    slots                = list(string)

    application_stack = object({
      current_stack  = string
      dotnet_version = optional(string)
      java_version   = optional(string)
      php_version    = optional(string)
      node_version   = optional(string)
    })
  })

  description = "The options for the app service"

  validation {
    condition     = contains(["dotnet", "dotnetcore", "java", "php", "python", "node"], var.webapp_options.application_stack.current_stack)
    error_message = "Please, choose among one of the following stacks: dotnet, dotnetcore, java, php, python or node."
  }
}

variable "appsvc_subnet_id" {
  type        = string
  description = "The subnet id where the app service will be integrated"
}

variable "frontend_subnet_id" {
  type        = string
  description = "The subnet id where the front door will be integrated"
}

variable "private_dns_zone" {
  type = object({
    id             = string
    name           = string
    resource_group = string
  })

  description = "The private dns zone id where the app service will be integrated"
}