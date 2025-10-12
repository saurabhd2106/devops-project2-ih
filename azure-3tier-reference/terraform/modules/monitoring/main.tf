resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "ai_frontend" {
  name                = "${var.prefix}-ai-frontend"
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
}

resource "azurerm_application_insights" "ai_backend" {
  name                = "${var.prefix}-ai-backend"
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
}

output "log_analytics_workspace_id" { value = azurerm_log_analytics_workspace.law.id }
output "ai_frontend_instrumentation_key" { value = azurerm_application_insights.ai_frontend.instrumentation_key }
output "ai_backend_instrumentation_key" { value = azurerm_application_insights.ai_backend.instrumentation_key }