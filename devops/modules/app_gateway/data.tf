data "azurerm_log_analytics_workspace" "ws" {
  count               = (var.log_analytics_workspace_name != null && var.log_analytics_workspace_rg != null) ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_rg
}
