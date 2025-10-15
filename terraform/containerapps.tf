# -----------------------------
# Log Analytics Workspace
# -----------------------------
resource "azurerm_log_analytics_workspace" "burgerbuilder_law" {
  name                = "burgerbuilder-law"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# -----------------------------
# Managed Identity
# -----------------------------
resource "azurerm_user_assigned_identity" "aca_identity" {
  name                = "burgerbuilder-aca-identity"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# -----------------------------
# Container Apps Environment (private)
# -----------------------------
resource "azurerm_container_app_environment" "burgerbuilder_env" {
  name                           = "burgerbuilder-aca-env"
  location                       = azurerm_resource_group.main.location
  resource_group_name            = azurerm_resource_group.main.name
  infrastructure_subnet_id       = azurerm_subnet.aca.id
  internal_load_balancer_enabled = true
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.burgerbuilder_law.id

  workload_profile {
    name                  = "default"
    workload_profile_type = "D4"
    minimum_count         = 1
    maximum_count         = 3
  }

  tags = {
    project     = "BurgerBuilder"
    environment = "development"
  }
}

# -----------------------------
# Frontend Container App
# -----------------------------
resource "azurerm_container_app" "frontend" {
  name                         = "burgerbuilder-frontend"
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.burgerbuilder_env.id
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_identity.id]
  }

  registry {
    server   = "burgerbuilderacr.azurecr.io"
    identity = azurerm_user_assigned_identity.aca_identity.id
  }

  ingress {
    external_enabled           = true
    target_port                = 80
    transport                  = "http"
    allow_insecure_connections = true


    traffic_weight {
      latest_revision = true
      percentage      = 100
    }

  }

  template {
    container {
      name   = "frontend"
      image  = "burgerbuilderacr.azurecr.io/burgerbuilder-frontend:3.0.0"
      cpu    = 1.0
      memory = "2Gi"

      env {
        name  = "VITE_API_BASE_URL"
        value = "http://${var.cors_allowed_origins}"
      }
    }
  min_replicas = 1
  max_replicas = 5
    
  }

  tags = {
    app         = "burgerbuilder"
    component   = "frontend"
    environment = "development"
  }
}

# -----------------------------
# Backend Container App
# -----------------------------
resource "azurerm_container_app" "backend" {
  name                         = "burgerbuilder-backend"
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.burgerbuilder_env.id
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_identity.id]
  }

  registry {
    server   = "burgerbuilderacr.azurecr.io"
    identity = azurerm_user_assigned_identity.aca_identity.id
  }

  ingress {
    external_enabled           = true
    target_port                = 8080
    transport                  = "http"
    allow_insecure_connections = true

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }

  }

  template {
    container {
      name   = "backend"
      image  = "burgerbuilderacr.azurecr.io/burgerbuilder-backend:latest"
      cpu    = 1.0
      memory = "2Gi"

      env {
        name  = "CORS_ALLOWED_ORIGINS"
        value = var.cors_allowed_origins
      }

      env {
        name  = "DB_DRIVER"
        value = var.db_driver
      }

      env {
        name  = "DB_HOST"
        value = var.db_host
      }

      env {
        name  = "DB_NAME"
        value = var.db_name
      }

      env {
        name  = "DB_PASSWORD"
        value = var.db_password
      }

      env {
        name  = "DB_PORT"
        value = var.db_port
      }

      env {
        name  = "DB_USERNAME"
        value = var.db_username
      }

      env {
        name  = "SERVER_PORT"
        value = var.server_port
      }

      env {
        name  = "SPRING_PROFILES_ACTIVE"
        value = var.spring_profiles_active
      }
    }
  min_replicas = 1
  max_replicas = 5

  }

  

  tags = {
    app         = "burgerbuilder"
    component   = "backend"
    environment = "development"
  }
}
