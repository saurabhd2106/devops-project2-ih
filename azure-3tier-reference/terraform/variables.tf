variable "subscription_id" {
  description = "Azure subscription id"
  type        = string
  default     = "4421688c-0a8d-4588-8dd0-338c5271d0af"
}

variable "prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "3tier"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "australiaeast"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-3tier"
}

variable "frontend_image" {
  description = "Frontend container image"
  type        = string
  default     = "yousefaloufi6/frontend-app:latest"
}

variable "backend_image" {
  description = "Backend container image"
  type        = string
  default     = "yousefaloufi6/backend-app:latest"
}

variable "db_admin" {
  type    = string
  default = "sqladmin"
}

variable "db_password" {
  type    = string
  default = "P@ssword1234!"
}
variable "existing_environment_id" {
  description = "Optional existing Container Apps environment resource id to reuse instead of creating a new one"
  type        = string
  default     = ""
}