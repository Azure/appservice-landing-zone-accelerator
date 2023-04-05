variable "vm_id" {
  type        = string
  description = "value of the vm id"
}

variable "enable_azure_ad_join" {
  type        = bool
  default     = true
  description = "True to enable Azure AD join of the VM."
}

variable "enroll_with_mdm" {
  type        = bool
  default     = true
  description = "True to enroll the device with an approved MDM provider like Intune."
}

variable "mdm_id" {
  type        = string
  default     = "0000000a-0000-0000-c000-000000000000"
  description = "The default value is the MDM Id for Intune, but you can use your own MDM id if you want to use a different MDM service."
}

variable "azure_cli_commands" {
  type        = string
  default     = ""
  description = "String with the list of Azure CLI commands to be executed on the VM, separated by a semicolon."
}

variable "install_ssms" {
  type        = bool
  default     = false
  description = "True to install SQL Server Management Studio on the VM."
}

variable "devops_settings" {
  type = object({
    github_runner = optional(object({
      repository_url = string
      token          = string
    }))

    devops_agent = optional(object({
      organization_url = string
      token            = string
    }))
  })

  description = "The settings for the Azure DevOps agent or GitHub runner"

  default = {
    github_runner = null
    devops_agent  = null
  }
}