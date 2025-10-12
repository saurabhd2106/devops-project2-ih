locals {
  workspace_id = coalesce(
    var.log_analytics_workspace_id,
    try(data.azurerm_log_analytics_workspace.ws[0].id, null)
  )
}
