
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "subnet_id"           { type = string }

variable "public_ip_id"        { type = string }

variable "frontend_fqdn"         { type = string }
variable "backend_internal_fqdn" { type = string }

variable "frontend_port" { type = number }
variable "backend_port"  { type = number }

variable "enable_diagnostics" {
  type    = bool
  default = false
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "log_analytics_workspace_name" {
  type    = string
  default = null
}

variable "log_analytics_workspace_rg" {
  type    = string
  default = null
}



variable "tags" {
  type    = map(string)
  default = {}
}
