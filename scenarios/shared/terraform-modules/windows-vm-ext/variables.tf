variable "vm_id" {
  type        = string
  description = "value of the vm id"
}

variable "install_extensions" {
  type    = bool
  default = false
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

variable "remote_exec_commands" {
  type        = list(string)
  default     = []
  description = "values to pass to the remote-exec provisioner"
}