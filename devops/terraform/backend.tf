terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-Abdullah-Alotaibi"
    storage_account_name = "tfstateabdullahalotaibi"
    container_name       = "tfstate-abdullah-alotaibi"
    key                  = "dev.terraform.tfstate"
  }
}
