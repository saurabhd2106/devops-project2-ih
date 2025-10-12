# terraform/variables.tf (root)
variable "rg_name"        { type = string }
variable "location" {
  type    = string
  default = "uksouth"
}
variable "tags"           { type = map(string) }

variable "vnet_name"      { type = string }
variable "address_space"  { type = list(string) }
variable "subnets" {
  type = map(object({
    name           = string
    address_prefix = list(string)
  }))
}
variable "nsg_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}
variable "private_endpoints" {
  type = map(object({
    subnet_name       = string
    resource_id       = string
    subresource_names = list(string)
  }))
}

variable "sql_admin_login"    { type = string }
variable "sql_admin_password" {
  type      = string
  sensitive = true
}

variable "frontend_image" {
  type = string
  description = "Full image reference for FE (e.g. acr.azurecr.io/frontend:<sha>)"
}

variable "backend_image" {
  type = string
  description = "Full image reference for BE (e.g. acr.azurecr.io/backend:<sha>)"
}
variable "frontend_port"  { type = number }
variable "backend_port"   { type = number }

variable "frontend_cpu"    { type = number }
variable "frontend_memory" { type = string }
variable "backend_cpu"     { type = number }
variable "backend_memory"  { type = string }

variable "frontend_min_replicas" { type = number }
variable "frontend_max_replicas" { type = number }
variable "backend_min_replicas"  { type = number }
variable "backend_max_replicas"  { type = number }

variable "acr_name"           { type = string }
variable "acr_resource_group" { type = string }
