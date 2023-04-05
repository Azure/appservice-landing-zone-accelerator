variable "vm_name" {
  description = "name of the virtual machine"
}

variable "resource_group" {
  type        = string
  description = "The name of the resource group where all resources should be created."
}

variable "location" {
  type        = string
  description = "The location (Azure region) where the resources should be created."
}

variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })

  description = "The identity type and the list of identities ids"

  default = {
    type         = "SystemAssigned"
    identity_ids = []
  }

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    error_message = "Please, choose among one of the following identity types: SystemAssigned, UserAssigned or SystemAssigned, UserAssigned."
  }
}

variable "admin_username" {
  type    = string
  default = null
}

variable "admin_password" {
  type    = string
  default = null
}

variable "aad_admin_username" {
  type        = string
  description = "The Azure AD username for the VM admin account."
}

variable "vm_subnet_id" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B2ms"
}

variable "vm_image_publisher" {
  type    = string
  default = "MicrosoftWindowsDesktop"
}

variable "vm_image_offer" {
  type    = string
  default = "windows-11"
}

variable "vm_image_sku" {
  type    = string
  default = "win11-22h2-pro"
}

variable "vm_image_version" {
  type    = string
  default = "latest"
}
