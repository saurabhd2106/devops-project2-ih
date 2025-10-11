output "vnet_id" {
  description = "ID of the created VNet"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  description = "IDs of all created subnets"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}


output "private_endpoint_ids" {
  description = "IDs of created private endpoints"
  value       = { for k, v in azurerm_private_endpoint.private_endpoints : k => v.id }
}
