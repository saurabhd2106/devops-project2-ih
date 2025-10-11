output "server_id" {
  value = azurerm_mssql_server.sql.id
}

output "fqdn" {
  value = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "sql_fqdn" {
  description = "Fully qualified domain name of the SQL server"
  value       = azurerm_mssql_server.sql.fully_qualified_domain_name
}
