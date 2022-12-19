variable "vm_name" {
  description = "name of the virtual machine"
}

variable "resource_group" {
  type        = string
  description = "The name of the resource group where all resources in this example should be created."
}


variable "location" {
  type = string
}

variable "aad_admin_group_object_id" {
  type = string
  description = "value of the object id of the Azure AD group that will be assigned as the admin of the VM"
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type = string
}

variable "vm_subnet_id" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B2ms"
}

variable "install_extensions" {
  type    = bool
  default = false
}

variable "enable_jit_access" {
  type    = bool
  default = false
}