
module "resource_group" {
  source   = "../modules/resource_group"
  rg_name  = var.rg_name
  location = var.location
  tags     = var.tags
}

module "network" {
  source = "../modules/network"

  resource_group_name = module.resource_group.rg_name
  location            = var.location
  nsg_name            = "nsg-${terraform.workspace}"

  vnet_name     = var.vnet_name
  address_space = var.address_space
  subnets       = var.subnets
  nsg_rules     = var.nsg_rules
  private_endpoints = {}
  tags = var.tags
}

locals {
  environment_vars = "${path.module}/environments/${terraform.workspace}/main.tfvars"
}

module "sql_database" {
  source = "../modules/sql_database"

  resource_group_name = module.resource_group.rg_name
  location            = var.location

  server_name            = "sql-${terraform.workspace}-abdullah-alotaibi"
  administrator_login    = var.sql_admin_login
  administrator_password = var.sql_admin_password

  database_name = "appdb-${terraform.workspace}-Abdullah-Alotaibi"
  tags          = var.tags

  pe_subnet_id             = module.network.subnet_ids["private"]
  create_private_dns_zone  = true
  vnet_id                  = module.network.vnet_id
}

resource "azurerm_public_ip" "agw_pip" {
  name                = "pip-agw-${terraform.workspace}"
  location            = var.location
  resource_group_name = module.resource_group.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

module "container_apps" {
  source = "../modules/container_apps"

  resource_group_name = module.resource_group.rg_name
  location            = var.location
  tags                = var.tags

  aca_subnet_id = module.network.subnet_ids["aca"]

  env_name      = "acaenv-${terraform.workspace}"
  frontend_name = "acafe-${terraform.workspace}"
  backend_name  = "acabe-${terraform.workspace}"

  frontend_image = var.frontend_image
  backend_image  = var.backend_image
  frontend_port  = var.frontend_port
  backend_port   = var.backend_port

  frontend_cpu    = var.frontend_cpu
  frontend_memory = var.frontend_memory
  backend_cpu     = var.backend_cpu
  backend_memory  = var.backend_memory

  frontend_min_replicas = var.frontend_min_replicas
  frontend_max_replicas = var.frontend_max_replicas
  backend_min_replicas  = var.backend_min_replicas
  backend_max_replicas  = var.backend_max_replicas

    backend_env = {
    SPRING_DATASOURCE_URL               = "jdbc:sqlserver://${module.sql_database.sql_fqdn}:1433;databaseName=appdb-${terraform.workspace}-Abdullah-Alotaibi;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30"
    SPRING_DATASOURCE_USERNAME          = var.sql_admin_login
    SPRING_DATASOURCE_PASSWORD          = var.sql_admin_password
    SPRING_DATASOURCE_DRIVER_CLASS_NAME = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
    MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE = "health,info"
    SPRING_MVC_CORS_ALLOWED_ORIGINS     = "http://${azurerm_public_ip.agw_pip.ip_address},http://localhost:3000,http://localhost:5173"
  }


  acr_name           = var.acr_name
  acr_resource_group = var.acr_resource_group

  appgw_public_ip = azurerm_public_ip.agw_pip.ip_address
}

module "app_gateway" {
  source = "../modules/app_gateway"

  resource_group_name = module.resource_group.rg_name
  location            = var.location
  subnet_id           = module.network.subnet_ids["agw"]

  public_ip_id = azurerm_public_ip.agw_pip.id

  frontend_fqdn         = module.container_apps.frontend_fqdn_internal
  backend_internal_fqdn = module.container_apps.backend_fqdn_internal

  frontend_port = var.frontend_port
  backend_port  = var.backend_port

  log_analytics_workspace_id = module.container_apps.log_analytics_workspace_id

  autoscale_min_capacity = 1
  autoscale_max_capacity = 3
  tags = var.tags
}
