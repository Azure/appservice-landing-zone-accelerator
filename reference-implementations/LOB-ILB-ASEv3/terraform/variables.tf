variable "workloadName" {
  description = "A short name for the workload being deployed"
  type        = string
  default     = "sam"
}

variable "environment" {
  description = "The environment for which the deployment is being executed"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The Azure location where all resources should be created"
  type        = string
  default     = "westus2"
}