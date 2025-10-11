# terraform/environments/dev/main.tfvars
rg_name  = "rg-dev-Abdullah-Alotaibi"
location = "uksouth"

tags = {
  Owner  = "Abdullah-Alotaibi"
  Client = "Abdullah-Alotaibi"
  Env    = "dev"
}

vnet_name     = "vnet-dev-Abdullah-Alotaibi"
address_space = ["10.0.0.0/16"]

subnets = {
  frontend = { name = "snet-frontend", address_prefix = ["10.0.1.0/24"] }
  backend  = { name = "snet-backend",  address_prefix = ["10.0.2.0/24"] }
  private  = { name = "snet-private",  address_prefix = ["10.0.3.0/24"] }
  aca      = { name = "snet-aca",      address_prefix = ["10.0.4.0/23"] }
  agw      = { name = "snet-agw",      address_prefix = ["10.0.6.0/27"] }
}

nsg_rules = [
  {
    name                  = "AllowHTTP", priority = 100, direction = "Inbound", access = "Allow",
    protocol              = "Tcp", source_port_range = "*", destination_port_range = "80",
    source_address_prefix = "*", destination_address_prefix = "*"
  },
  {
    name                  = "AllowHTTPS", priority = 110, direction = "Inbound", access = "Allow",
    protocol              = "Tcp", source_port_range = "*", destination_port_range = "443",
    source_address_prefix = "*", destination_address_prefix = "*"
  }
]

private_endpoints = {}

sql_admin_login    = "sqladmin"
sql_admin_password = "hkhA12780-@"

frontend_image = "acralotaibi826.azurecr.io/frontend:v11"
backend_image  = "acralotaibi826.azurecr.io/backend:v9"

frontend_port = 80
backend_port  = 8080

frontend_cpu    = 0.5
frontend_memory = "1.0Gi"
backend_cpu     = 0.5
backend_memory  = "1.0Gi"

frontend_min_replicas = 1
frontend_max_replicas = 3
backend_min_replicas  = 1
backend_max_replicas  = 3

acr_name           = "acralotaibi826"
acr_resource_group = "rg-dev-Abdullah-Alotaibi"
