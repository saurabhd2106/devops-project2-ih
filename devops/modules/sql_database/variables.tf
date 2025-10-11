variable "resource_group_name" { type = string }
variable "location"            { type = string }

variable "server_name"         { type = string }
variable "administrator_login" { type = string }
variable "administrator_password" { type = string }

variable "database_name"       { type = string }
variable "tags"                { type = map(string) }


variable "pe_subnet_id"        { type = string }


variable "vnet_id" {
  type    = string
  default = null
}

variable "create_private_dns_zone" {
  type    = bool
  default = true
}
