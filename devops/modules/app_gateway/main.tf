
locals {
  agw_name = "agw-${terraform.workspace}"
}

resource "azurerm_application_gateway" "agw" {
  name                = local.agw_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = var.autoscale_min_capacity
    max_capacity = var.autoscale_max_capacity
  }

  gateway_ip_configuration {
    name      = "gw-ipcfg"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "fe-port"
    port = var.frontend_port
  }

  frontend_ip_configuration {
    name                 = "fe-ip"
    public_ip_address_id = var.public_ip_id
  }

  backend_address_pool {
    name  = "fe-pool"
    fqdns = [var.frontend_fqdn]
  }

  backend_address_pool {
    name  = "be-pool"
    fqdns = [var.backend_internal_fqdn]
  }

  probe {
    name        = "fe-probe"
    protocol    = "Https"
    path        = "/"
    interval    = 30
    timeout     = 30
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = true
    match { status_code = ["200-399"] }
  }

  probe {
    name        = "be-probe"
    protocol    = "Https"
    path        = "/actuator/health"
    interval    = 10
    timeout     = 60
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = true
    match { status_code = ["200-399"] }
  }

  backend_http_settings {
    name                                = "fe-http-settings"
    protocol                            = "Https"
    port                                = 443
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = "fe-probe"
    cookie_based_affinity               = "Disabled"
  }

  backend_http_settings {
    name                                = "be-http-settings"
    protocol                            = "Https"
    port                                = 443
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = "be-probe"
    cookie_based_affinity               = "Disabled"
  }

  http_listener {
    name                           = "fe-listener"
    frontend_ip_configuration_name = "fe-ip"
    frontend_port_name             = "fe-port"
    protocol                       = "Http"
  }

  url_path_map {
    name = "fe-be-pathmap"

    default_backend_address_pool_name  = "fe-pool"
    default_backend_http_settings_name = "fe-http-settings"

    path_rule {
      name                       = "api-to-backend"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "be-pool"
      backend_http_settings_name = "be-http-settings"
    }
  }

  request_routing_rule {
    name               = "rule-path"
    rule_type          = "PathBasedRouting"
    http_listener_name = "fe-listener"
    url_path_map_name  = "fe-be-pathmap"
    priority           = 100
  }
}

resource "azurerm_monitor_diagnostic_setting" "agw_diag" {
  count                      = var.log_analytics_workspace_id == null ? 0 : 1
  name                       = "agw-diag"
  target_resource_id         = azurerm_application_gateway.agw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log    { category = "ApplicationGatewayAccessLog" }
  enabled_log    { category = "ApplicationGatewayPerformanceLog" }
  enabled_log    { category = "ApplicationGatewayFirewallLog" }
  enabled_metric { category = "AllMetrics" }
}
