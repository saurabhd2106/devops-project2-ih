variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "frontend_fqdn" { type = string }
variable "backend_fqdn" { type = string }
variable "appgw_subnet_id" { type = string }
variable "prefix" {
  type        = string
  description = "Name prefix used when creating the Application Gateway"
  default     = "app"
}

variable "ssl_certificate_name" {
  type        = string
  description = "Optional name of an existing SSL certificate resource to reference for HTTPS listeners"
  default     = null
}