variable "rg_name" {
  description = "rg-terraform-state-Abdullah-Alotaib"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
  default     = "uksouth"
}

variable "tags" {
  description = "rg-terraform-state-Abdullah-Alotaib-1"
  type        = map(string)
  default = {
    Owner  = "Abdullah-Alotaibi"
    Client = "Abdullah-Alotaibi"
    Env    = "dev"
  }
}
