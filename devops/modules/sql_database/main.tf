
resource "azurerm_mssql_server" "sql" {
  name                          = var.server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.administrator_login
  administrator_login_password  = var.administrator_password
  public_network_access_enabled = false
  tags = var.tags
}

resource "azurerm_mssql_database" "db" {
  name      = var.database_name
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "S0"
  tags      = var.tags
}


resource "azurerm_private_endpoint" "sql_pe" {
  name                = "${var.server_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${var.server_name}-sql-connection"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  tags = var.tags
}


resource "azurerm_private_dns_zone" "sql_privatelink" {
  count               = var.create_private_dns_zone ? 1 : 0
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  count                 = var.create_private_dns_zone ? 1 : 0

  name                  = "${var.server_name}-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_privatelink[0].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  lifecycle {
    precondition {
      condition     = var.vnet_id != null
      error_message = "vnet_id must be provided (non-null) to create the Private DNS zone link."
    }
  }
}



resource "azurerm_private_dns_a_record" "sql" {
  count               = var.create_private_dns_zone ? 1 : 0
  name                = azurerm_mssql_server.sql.name  # مو FQDN
  zone_name           = azurerm_private_dns_zone.sql_privatelink[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [
    azurerm_private_endpoint.sql_pe.private_service_connection[0].private_ip_address
  ]
}

