variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "aca_subnet_id" {
  type = string
}

variable "env_name" {
  type = string
}

variable "frontend_name" {
  type = string
}

variable "backend_name" {
  type = string
}

variable "frontend_image" {
  type = string
}

variable "backend_image" {
  type = string
}

variable "frontend_port" {
  type = number
}

variable "backend_port" {
  type = number
}

variable "frontend_cpu" {
  type = number
}

variable "frontend_memory" {
  type = string
}

variable "backend_cpu" {
  type = number
}

variable "backend_memory" {
  type = string
}

variable "frontend_min_replicas" {
  type = number
}

variable "frontend_max_replicas" {
  type = number
}

variable "backend_min_replicas" {
  type = number
}

variable "backend_max_replicas" {
  type = number
}

variable "backend_env" {
  type    = map(string)
  default = {}
}

variable "acr_name" {
  type = string
}

variable "acr_resource_group" {
  type = string
}

variable "appgw_public_ip" {
  type = string
}
