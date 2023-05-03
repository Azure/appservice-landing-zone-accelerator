variable "vmname" {
  description = "name of the virtual machine"
}
variable "resourceGroupName" {
  type = string
}

variable "location" {
  type = string
}

variable "adminUserName" {
  type = string
}

variable "adminPassword" {
  type = string
}

variable "cidr" {
  type = string
}

variable "installDevOpsAgent" {
  type    = bool
  default = false
}