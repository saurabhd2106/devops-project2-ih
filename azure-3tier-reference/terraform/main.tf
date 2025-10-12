// Root module for Azure 3-tier reference
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.50"
    }
  }
}

provider "azurerm" {
  features {}
}

# Remote state is left for you to configure. Use backend "azurerm" with storage account.

module "network" {
  source              = "./modules/network"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = module.network.resource_group_name
  location            = var.location
  prefix              = var.prefix
}

module "sql" {
  source              = "./modules/sql"
  resource_group_name = module.network.resource_group_name
  location            = var.location
  db_admin            = var.db_admin
  db_password         = var.db_password
  db_subnet_id        = module.network.db_pe_subnet_id
  vnet_id             = module.network.vnet_id
  prefix              = var.prefix
}

module "containerapps" {
  source                = "./modules/containerapps"
  resource_group_name   = module.network.resource_group_name
  location              = var.location
  prefix                = var.prefix
  environment_subnet_id = module.network.aca_env_subnet_id
  frontend_image        = var.frontend_image
  backend_image         = var.backend_image
  environment_id        = var.existing_environment_id
  # User-specified DB settings
  # Use the SQL server FQDN from the sql module (was a hard-coded placeholder 'aloufi')
  db_host = module.sql.db_fqdn
  # The database name comes from the sql module
  db_name = module.sql.db_name
  # Use the fully-qualified SQL login (user@servername)
  db_user = "yousefaloufi1@3tier-sqlserver"
  # Reuse the existing db_password variable instead of duplicating a literal here
  db_pass = var.db_password
}

module "appgw" {
  source              = "./modules/appgw"
  resource_group_name = module.network.resource_group_name
  location            = var.location
  prefix              = var.prefix
  frontend_fqdn       = module.containerapps.frontend_fqdn
  backend_fqdn        = module.containerapps.backend_fqdn
  appgw_subnet_id     = module.network.appgw_subnet_id
}

output "appgw_public_ip" {
  value = module.appgw.appgw_public_ip
}

output "frontend_fqdn" {
  value = module.containerapps.frontend_fqdn
}

output "backend_fqdn" {
  value = module.containerapps.backend_fqdn
}
