variable "frontdoor_profile_id" {
  type        = string
  description = "The front door profile id"
}

variable "endpoint_name" {
  type        = string
  description = "The name of the front door endpoint."
}

variable "web_app_hostname" {
  type        = string
  description = "The web app hostname"
}

variable "web_app_id" {
  type        = string
  description = "The web app id"
}

variable "private_link_target_type" {
  type        = string
  description = "The private link target type"
}

variable "location" {
  type        = string
  description = "The Azure region of the web app"
}