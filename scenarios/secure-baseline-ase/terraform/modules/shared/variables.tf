variable "resourceSuffix" {
  type        = string
  description = "resourceSuffix"
}

variable "resourceGroupName" {
  type = string
}

variable "location" {
  type = string
}

variable "adminUsername" {
  type = string
}

variable "adminPassword" {
  type    = string
  default = null
}

variable "devOpsVMSubnetId" {
  type = string
}

variable "jumpboxVMSubnetId" {
  type = string
}

variable "bastionSubnetId" {
  type = string
}

variable "tenantId" {
  type = string
}
