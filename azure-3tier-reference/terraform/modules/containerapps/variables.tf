variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "environment_subnet_id" { type = string }
variable "frontend_image" { type = string }
variable "backend_image" { type = string }
variable "db_host" {
  type    = string
  default = "3tier-sqlserver.database.windows.net"
}
variable "db_name" { type = string }
variable "db_user" { type = string }
variable "db_pass" { type = string }
variable "environment_id" {
  description = "(Optional) Existing Container Apps Environment resource id. If provided, Terraform will not create a new environment."
  type        = string
  default     = ""
}

variable "prefix" {
  type        = string
  description = "Name prefix used for container apps and environment"
  default     = "3tier"
}