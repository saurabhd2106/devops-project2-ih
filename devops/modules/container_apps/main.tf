
resource "azurerm_log_analytics_workspace" "la" {
  name                = lower("log-aca-${var.env_name}")
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group
}

resource "azurerm_user_assigned_identity" "aca_pull" {
  name                = lower("uami-aca-pull-${var.env_name}")
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aca_pull.principal_id
}

resource "azurerm_container_app_environment" "env" {
  name                           = lower(var.env_name)
  location                       = var.location
  resource_group_name            = var.resource_group_name
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.la.id
  infrastructure_subnet_id       = var.aca_subnet_id
  internal_load_balancer_enabled = false
  tags                           = var.tags
}

resource "azurerm_container_app" "backend" {
  name                         = lower(var.backend_name)
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_pull.id]
  }

  registry {
    server   = data.azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.aca_pull.id
  }

  template {
    container {
      name   = "backend"
      image  = var.backend_image
      cpu    = var.backend_cpu
      memory = var.backend_memory

      readiness_probe {
        transport               = "HTTP"
        port                    = var.backend_port
        path                    = "/actuator/health/readiness"
        interval_seconds        = 10
        timeout                 = 10
        failure_count_threshold = 10
      }

      liveness_probe {
        transport               = "TCP"
        port                    = var.backend_port
        interval_seconds        = 10
        timeout                 = 10
        failure_count_threshold = 18
      }

      dynamic "env" {
        for_each = var.backend_env
        content {
          name  = env.key
          value = env.value
        }
      }
    }

    termination_grace_period_seconds = 60
    min_replicas = var.backend_min_replicas
    max_replicas = var.backend_max_replicas
  }

  ingress {
    external_enabled = true
    target_port      = var.backend_port
    transport        = "http"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
    ip_security_restriction {
      name             = "Allow-AppGW"
      description      = "Only Application Gateway public IP"
      action           = "Allow"
      ip_address_range = "${var.appgw_public_ip}/32"
    }
  }

  tags = var.tags
}

resource "azurerm_container_app" "frontend" {
  name                         = lower(var.frontend_name)
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_pull.id]
  }

  registry {
    server   = data.azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.aca_pull.id
  }

  template {
    container {
      name   = "frontend"
      image  = var.frontend_image
      cpu    = var.frontend_cpu
      memory = var.frontend_memory

      readiness_probe {
        transport               = "HTTP"
        port                    = var.frontend_port
        path                    = "/"
        interval_seconds        = 10
        timeout                 = 5
        failure_count_threshold = 3
      }

      liveness_probe {
        transport               = "HTTP"
        port                    = var.frontend_port
        path                    = "/"
        interval_seconds        = 10
        timeout                 = 5
        failure_count_threshold = 3
      }

      env {
        name  = "PORT"
        value = tostring(var.frontend_port)
      }
       env {
        name  = "VITE_API_BASE_URL"
        value = "http://${var.appgw_public_ip}"
      }
    }

    min_replicas = var.frontend_min_replicas
    max_replicas = var.frontend_max_replicas
  }

  ingress {
    external_enabled = true
    target_port      = var.frontend_port
    transport        = "http"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
    ip_security_restriction {
      name             = "Allow-AppGW"
      description      = "Only Application Gateway public IP"
      action           = "Allow"
      ip_address_range = "${var.appgw_public_ip}/32"
    }
  }

  tags = var.tags
}
