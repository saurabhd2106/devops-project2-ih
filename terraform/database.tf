# -----------------------------
# SQL Server
# -----------------------------
resource "azurerm_mssql_server" "burgerbuilder_sql_server" {
  name                = "burgerbuilder-sqlserver"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  version             = "12.0"

  administrator_login          = var.db_username
  administrator_login_password = var.db_password

  public_network_access_enabled = false # 👈 disables public access

  tags = {
    project     = "BurgerBuilder"
    environment = "development"
  }
}

# -----------------------------
# SQL Database
# -----------------------------
resource "azurerm_mssql_database" "burgerbuilder_db" {
  name           = "burgerbuilder-db"
  server_id      = azurerm_mssql_server.burgerbuilder_sql_server.id
  sku_name       = "S0"
  max_size_gb    = 5
  zone_redundant = false

  tags = {
    project     = "BurgerBuilder"
    environment = "development"
  }
}

# -----------------------------
# Private DNS Zone
# -----------------------------
resource "azurerm_private_dns_zone" "burgerbuilder_sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

# Link DNS Zone to your VNet
resource "azurerm_private_dns_zone_virtual_network_link" "burgerbuilder_sql_dns_link" {
  name                  = "burgerbuilder-sql-dnslink"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.burgerbuilder_sql_dns.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

# -----------------------------
# Private Endpoint
# -----------------------------
resource "azurerm_private_endpoint" "burgerbuilder_sql_pe" {
  name                = "burgerbuilder-sql-pe"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.database.id

  private_service_connection {
    name                           = "burgerbuilder-sql-connection"
    private_connection_resource_id = azurerm_mssql_server.burgerbuilder_sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "burgerbuilder-sql-dnszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.burgerbuilder_sql_dns.id]
  }

  tags = {
    project     = "BurgerBuilder"
    environment = "development"
  }
}
