
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "subnet_id"           { type = string }

variable "public_ip_id"        { type = string }

variable "frontend_fqdn"         { type = string }
variable "backend_internal_fqdn" { type = string }

variable "frontend_port" { type = number }
variable "backend_port"  { type = number }

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "autoscale_min_capacity" {
  type    = number
  default = 1
}

variable "autoscale_max_capacity" {
  type    = number
  default = 3
}

variable "tags" {
  type    = map(string)
  default = {}
}
