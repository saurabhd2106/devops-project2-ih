output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "appgw_public_ip" {
  value = azurerm_public_ip.agw_pip.ip_address
}

output "frontend_vm_private_ip" { value = var.fe_ip }
output "backend_vm_private_ip" { value = var.api_ip }
output "ops_vm_private_ip" { value = var.ops_ip }

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "app_insights_connection_string" {
  value     = azurerm_application_insights.appi.connection_string
  sensitive = true
}
