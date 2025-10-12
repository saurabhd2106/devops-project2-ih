locals {
  use_existing_env = length(trimspace(var.environment_id)) > 0

  # Create a short deterministic, safe prefix from the md5 of the user-provided prefix.
  # This guarantees: lower-case hex characters, starts with a letter ('a'), and stays short.
  # Format: a + first 7 chars of md5(prefix) => total length 8
  safe_hash   = substr(md5(var.prefix), 0, 7)
  name_prefix = "a${local.safe_hash}"

  # If an existing environment id is provided, use it. Otherwise, if we created an env, use its first instance id.
  env_id = local.use_existing_env ? var.environment_id : (length(azurerm_container_app_environment.env) > 0 ? azurerm_container_app_environment.env[0].id : "")
}

resource "azurerm_container_app_environment" "env" {
  count                          = local.use_existing_env ? 0 : 1
  name                           = "aca-${local.name_prefix}-env"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  internal_load_balancer_enabled = true
  infrastructure_subnet_id       = var.environment_subnet_id
}

resource "azurerm_container_app" "frontend" {
  name                         = "${local.name_prefix}-frontend-app"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = local.env_id
  revision_mode                = "Single"
  template {
    container {
      name   = "frontend"
      image  = var.frontend_image
      cpu    = 0.5
      memory = "1Gi"
    }
  }
  ingress {
    external_enabled = false
    target_port      = 80
    transport        = "http"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

resource "azurerm_container_app" "backend" {
  name                         = "${local.name_prefix}-backend-app"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = local.env_id
  revision_mode                = "Single"
  template {
    container {
      name   = "backend"
      image  = var.backend_image
      cpu    = 0.5
      memory = "1Gi"
      env {
        name  = "DB_HOST"
        value = var.db_host
      }
      env {
        name  = "SPRING_DATASOURCE_URL"
        value = "jdbc:sqlserver://${var.db_host}:1433;database=${var.db_name};encrypt=true;trustServerCertificate=false;loginTimeout=30;"
      }
      env {
        name  = "SPRING_DATASOURCE_USERNAME"
        value = var.db_user
      }
      env {
        name  = "SPRING_DATASOURCE_PASSWORD"
        value = var.db_pass
      }
      env {
        name  = "DB_NAME"
        value = var.db_name
      }
      env {
        name  = "DB_USERNAME"
        value = var.db_user
      }
      env {
        name  = "DB_PASSWORD"
        value = var.db_pass
      }
    }
  }
  ingress {
    external_enabled = false
    target_port      = 8080
    transport        = "http"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

output "frontend_fqdn" {
  value = azurerm_container_app.frontend.ingress[0].fqdn
}

output "backend_fqdn" {
  value = azurerm_container_app.backend.ingress[0].fqdn
}

output "environment_id" {
  value = local.env_id
}