resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "snet-appgw"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "aca_env_subnet" {
  name                 = "snet-aca-env"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.2.0/23"]
}

resource "azurerm_subnet" "db_pe_subnet" {
  name                              = "snet-db-pe"
  resource_group_name               = azurerm_resource_group.rg.name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  address_prefixes                  = ["10.10.4.0/24"]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "ops_subnet" {
  name                 = "snet-ops"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.5.0/24"]
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "aca_env_subnet_id" {
  value = azurerm_subnet.aca_env_subnet.id
}

output "db_pe_subnet_id" {
  value = azurerm_subnet.db_pe_subnet.id
}

output "appgw_subnet_id" {
  value = azurerm_subnet.appgw_subnet.id
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}