resource "azurerm_public_ip" "pip" {
  name                = "appgw-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "appgw-${var.prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }
  gateway_ip_configuration {
    name      = "appgw-ip"
    subnet_id = var.appgw_subnet_id
  }
  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
  frontend_port {
    name = "http"
    port = 80
  }

  # HTTPS frontend port and listener intentionally omitted to avoid requiring an SSL certificate here.

  backend_address_pool {
    name  = "frontend-pool"
    fqdns = [var.frontend_fqdn]
  }

  backend_address_pool {
    name  = "backend-pool"
    fqdns = [var.backend_fqdn]
  }

  backend_http_settings {
    name                                = "http-settings"
    port                                = 80
    protocol                            = "Http"
    cookie_based_affinity               = "Disabled"
    # Ensure the Host header sent to backend matches the Container Apps FQDN
    host_name = var.backend_fqdn
  }

  probe {
    name                = "health-probe"
    protocol            = "Http"
    path                = "/actuator/health"
    port                = 80
    host                = var.backend_fqdn
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  http_listener {
    name                           = "listener-http"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  # HTTPS listener intentionally omitted in this module to avoid SSL cert management in the module.
  url_path_map {
    name                               = "urlmap"
    default_backend_address_pool_name  = "frontend-pool"
    default_backend_http_settings_name = "http-settings"
    path_rule {
      name                       = "api-rule"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "backend-pool"
      backend_http_settings_name = "http-settings"
    }
  }
  request_routing_rule {
    name               = "rule"
    rule_type          = "PathBasedRouting"
    http_listener_name = "listener-http"
    url_path_map_name  = "urlmap"
    priority           = 100
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  # Use a predefined SSL policy to ensure TLS 1.2+ and avoid deprecated protocol versions
  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401S"
  }
  lifecycle {
    # Workaround for provider returning computed backend_address_pool values that
    # don't correlate with planned set elements during apply (inconsistent final plan).
    # Ignoring changes to backend_address_pool lets terraform finish the apply.
    # Follow-up: refactor backend pools into standalone resources or upgrade the
    # azurerm provider to a version where this bug is fixed, then remove this.
    ignore_changes = [backend_address_pool]
  }

  depends_on = []
}

output "appgw_public_ip" { value = azurerm_public_ip.pip.ip_address }

output "appgw_id" { value = azurerm_application_gateway.appgw.id }