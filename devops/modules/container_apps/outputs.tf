output "environment_id" {
  description = "ACA environment resource ID"
  value       = azurerm_container_app_environment.env.id
}

# FQDN للفرونت (public ingress)
output "frontend_fqdn_internal" {
  value = azurerm_container_app.frontend.ingress[0].fqdn
}

output "backend_fqdn_internal" {
  value = azurerm_container_app.backend.ingress[0].fqdn
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.la.id
}