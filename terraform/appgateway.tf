# -----------------------------
# Public IP (for App Gateway)
# -----------------------------
resource "azurerm_public_ip" "burgerbuilder_appgw_pip" {
  name                = "burgerbuilder-appgw-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Project     = "BurgerBuilder"
    Environment = "Production"
    Owner       = "Selwan"
  }
}

# -----------------------------
# Application Gateway (Standard v2, HTTP only)
# -----------------------------
resource "azurerm_application_gateway" "burgerbuilder_appgw" {
  name                = "burgerbuilder-appgw"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Standard_v2 SKU — no WAF, no HTTPS
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  # Gateway IP Configuration
  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.appgw.id
  }

  # Frontend Port (HTTP only)
  frontend_port {
    name = "frontendPort"
    port = 80
  }

  # Frontend IP Configuration
  frontend_ip_configuration {
    name                 = "frontendPublicIp"
    public_ip_address_id = azurerm_public_ip.burgerbuilder_appgw_pip.id
  }

  # -----------------------------
  # Backend Address Pools
  # -----------------------------
  backend_address_pool {
    name  = "frontendPool"
    fqdns = ["burgerbuilder-frontend.nicebeach-3608a673.swedencentral.azurecontainerapps.io"]

  }

  backend_address_pool {
    name  = "backendPool"
    fqdns = ["burgerbuilder-backend.nicebeach-3608a673.swedencentral.azurecontainerapps.io"]

    # use service_name.${container_apps_environment_default_domain}
    # burgerbuilder-backend.nicebeachwhatever......
  }

  # -----------------------------
  # Health Probes
  # -----------------------------
  probe {
    name                                      = "frontend-probe"
    protocol                                  = "Http"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 10
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
  }

  probe {
    name                                      = "backend-probe"
    protocol                                  = "Http"
    path                                      = "/actuator/health"
    interval                                  = 30
    timeout                                   = 10
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
  }

  # -----------------------------
  # Backend HTTP Settings
  # -----------------------------
  backend_http_settings {
    name                                = "frontendHttpSetting"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true
    probe_name                          = "frontend-probe"
    cookie_based_affinity               = "Disabled"
  }

  backend_http_settings {
    name                                = "backendHttpSetting"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true
    probe_name                          = "backend-probe"
    cookie_based_affinity               = "Disabled"
  }

  # -----------------------------
  # Listener (HTTP only)
  # -----------------------------
  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "frontendPublicIp"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }

  # -----------------------------
  # URL Path Map (Routing)
  # -----------------------------
  url_path_map {
    name = "pathBasedRouting"

    # Default route → frontend
    default_backend_address_pool_name  = "frontendPool"
    default_backend_http_settings_name = "frontendHttpSetting"

    # API route → backend
    path_rule {
      name                       = "apiRule"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "backendPool"
      backend_http_settings_name = "backendHttpSetting"
    }
  }

  # -----------------------------
  # Routing Rule (HTTP only)
  # -----------------------------
  request_routing_rule {
    name               = "pathBasedRule"
    rule_type          = "PathBasedRouting"
    http_listener_name = "httpListener"
    url_path_map_name  = "pathBasedRouting"
    priority           = 100
  }

  tags = {
    Project     = "BurgerBuilder"
    Environment = "Production"
    Owner       = "Selwan"
  }
}
