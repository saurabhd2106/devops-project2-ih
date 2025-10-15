terraform {
  backend "azurerm" {
    resource_group_name  = "selwan-tfstate"
    storage_account_name = "selwanstorageacc"
    container_name       = "selwan-tfstate"
    key                  = "terraform.tfstate"
  }
}
