output "rg_name" {
  description = "Resource Group "
  value       = azurerm_resource_group.rg.name
}

output "rg_location" {
  description = "Resource Group location"
  value       = azurerm_resource_group.rg.location
}
