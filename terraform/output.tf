# -----------------------------
# Resource Group & VNet
# -----------------------------
output "resource_group_name" {
  description = "Name of the Resource Group"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.main.id
}

output "appgw_subnet_id" {
  description = "Application Gateway Subnet ID"
  value       = azurerm_subnet.appgw.id
}

output "aca_subnet_id" {
  description = "Container Apps Subnet ID"
  value       = azurerm_subnet.aca.id
}

output "database_subnet_id" {
  description = "Database (SQL Private Endpoint) Subnet ID"
  value       = azurerm_subnet.database.id
}

# -----------------------------
# Container Apps Environment
# -----------------------------
output "container_apps_environment_id" {
  description = "The ID of the Azure Container Apps Environment"
  value       = azurerm_container_app_environment.burgerbuilder_env.id
}

output "container_apps_environment_name" {
  description = "The name of the Azure Container Apps Environment"
  value       = azurerm_container_app_environment.burgerbuilder_env.name
}

# -----------------------------
# Frontend & Backend Container Apps
# -----------------------------
output "frontend_containerapp_name" {
  description = "Name of the BurgerBuilder frontend container app"
  value       = azurerm_container_app.frontend.name
}

output "backend_containerapp_name" {
  description = "Name of the BurgerBuilder backend container app"
  value       = azurerm_container_app.backend.name
}

output "frontend_containerapp_id" {
  description = "Resource ID of the frontend container app"
  value       = azurerm_container_app.frontend.id
}

output "backend_containerapp_id" {
  description = "Resource ID of the backend container app"
  value       = azurerm_container_app.backend.id
}

# Outputs — Private DNS Zone for ACA Internal Domain

output "private_dns_zone_name" {
  description = "The name of the Private DNS zone used for resolving internal Azure Container Apps FQDNs."
  value       = azurerm_private_dns_zone.aca_internal.name
}

output "private_dns_zone_id" {
  description = "The resource ID of the Private DNS zone."
  value       = azurerm_private_dns_zone.aca_internal.id
}

output "private_dns_vnet_link_name" {
  description = "The name of the VNet link associated with the Private DNS zone."
  value       = azurerm_private_dns_zone_virtual_network_link.aca_dns_link.name
}

output "private_dns_vnet_link_id" {
  description = "The resource ID of the VNet link associated with the Private DNS zone."
  value       = azurerm_private_dns_zone_virtual_network_link.aca_dns_link.id
}

output "sql_private_fqdn" {
  description = "The private endpoint FQDN for the SQL Server"
  value       = azurerm_private_dns_zone.burgerbuilder_sql_dns.name
}
