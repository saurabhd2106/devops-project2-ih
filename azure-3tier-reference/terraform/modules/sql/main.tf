resource "azurerm_mssql_server" "sql" {
  name                         = "${var.prefix}-sqlserver"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.db_admin
  administrator_login_password = var.db_password
}

resource "azurerm_mssql_database" "db" {
  name      = "${var.prefix}-db"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "S0"
}

resource "azurerm_private_endpoint" "sql_pe" {
  name                = "sql-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.db_subnet_id
  private_service_connection {
    name                           = "sql-pe-conn"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "sql-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = var.vnet_id
}

output "db_fqdn" {
  value = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "db_name" {
  value = azurerm_mssql_database.db.name
}