############################################
# Web Application Firewall (WAF) Policy v2
############################################
resource "azurerm_web_application_firewall_policy" "waf" {
  name                = "${var.name_prefix}-waf"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  policy_settings {
    enabled            = true
    mode               = "Prevention" # لو تبغي مراقبة فقط: "Detection"
    request_body_check = true
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  tags = var.tags
}

############################################
# Application Gateway (WAF_v2) + Routing
############################################
resource "azurerm_application_gateway" "agw" {
  name                = "${var.name_prefix}-agw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  enable_http2        = true

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  # نربط سياسة الـ WAF بالبوابة
  firewall_policy_id = azurerm_web_application_firewall_policy.waf.id

  gateway_ip_configuration {
    name      = "gw-ipcfg"
    subnet_id = azurerm_subnet.snet_appgw.id
  }

  frontend_port {
    name = "fp-80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "fip-public"
    public_ip_address_id = azurerm_public_ip.agw_pip.id
  }

  # Backend Pools
  backend_address_pool {
    name         = "be-frontend"
    ip_addresses = [var.fe_ip]
  }

  backend_address_pool {
    name         = "be-backend"
    ip_addresses = [var.api_ip]
  }

  # Probes (انتبهي: status_code بصيغة مفرد وقائمة)
  probe {
    name                                      = "probe-frontend"
    protocol                                  = "Http"
    path                                      = var.frontend_probe_path
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399"]
    }
  }

  probe {
    name                                      = "probe-backend"
    protocol                                  = "Http"
    path                                      = var.backend_probe_path
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399"]
    }
  }

  # HTTP Settings
  backend_http_settings {
    name                                = "http-fe"
    protocol                            = "Http"
    port                                = var.frontend_port
    request_timeout                     = 30
    probe_name                          = "probe-frontend"
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                                = "http-api"
    protocol                            = "Http"
    port                                = var.backend_port
    request_timeout                     = 30
    probe_name                          = "probe-backend"
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = true
  }

  # Listener 80
  http_listener {
    name                           = "listener-80"
    frontend_ip_configuration_name = "fip-public"
    frontend_port_name             = "fp-80"
    protocol                       = "Http"
  }

  # Path-based routing: "/" -> frontend, "/api/*" -> backend
  url_path_map {
    name                               = "paths"
    default_backend_address_pool_name  = "be-frontend"
    default_backend_http_settings_name = "http-fe"

    path_rule {
      name                       = "api-rule"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "be-backend"
      backend_http_settings_name = "http-api"
    }
  }

  request_routing_rule {
    name               = "rule1"
    rule_type          = "PathBasedRouting"
    http_listener_name = "listener-80"
    url_path_map_name  = "paths"
    priority           = 100
  }

  tags = var.tags
}
