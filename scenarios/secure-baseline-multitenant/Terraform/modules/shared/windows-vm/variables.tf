variable "vm_name" {
  description = "name of the virtual machine"
}

variable "unique_id" {
  type        = string
  description = "A unique identifier"
}

variable "resource_group" {
  type        = string
  description = "The name of the resource group where all resources in this example should be created."
}

variable "location" {
  type = string
}

variable "admin_username" {
  type = string
  default = null
}

variable "admin_password" {
  type = string
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

variable "install_extensions" {
  type    = bool
  default = false
}

variable "enable_azure_ad_join" {
  type    = bool
  default = true
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

variable "firewall_rules" {
  type        = map
  description = "The list of firewall rules deployed in the Azure Firewall. This is a dependency for deploying the VM extensions."
}