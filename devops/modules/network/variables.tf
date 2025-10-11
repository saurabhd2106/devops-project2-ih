variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
}

variable "address_space" {
  description = "Address space for the VNet"
  type        = list(string)
}

variable "subnets" {
  description = "Subnets configuration"
  type = map(object({
    name           = string
    address_prefix = list(string)
  }))
}


variable "nsg_name" {
  description = "Network Security Group name"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}


variable "private_endpoints" {
  description = "Private endpoints configuration"
  type = map(object({
    subnet_name        = string
    resource_id        = string
    subresource_names  = list(string)
  }))
  default = {}
} 

variable "nsg_rules" {
  description = "Network security group rules"
  type = list(object({
    name                      = string
    priority                  = number
    direction                 = string
    access                    = string
    protocol                  = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}




