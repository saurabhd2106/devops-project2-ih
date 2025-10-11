
output "agw_id" {
  value = azurerm_application_gateway.agw.id
}

output "public_ip_id" {
  value = var.public_ip_id
}

output "http_url" {
  value = "http://placeholder"
}

output "log_analytics_workspace_id" {
  value = var.log_analytics_workspace_id
}
