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
  default = "Standard_F2"
}

variable "installDevOpsAgent" {
  type    = bool
  default = false
}
