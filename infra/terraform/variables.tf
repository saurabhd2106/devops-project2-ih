variable "location" {
  type    = string
  default = "Italy North" # المنطقة المطلوبة
}

variable "resource_group_name" {
  type    = string
  default = "project2-teaf" # اسم الـ RG المطلوب
}

variable "name_prefix" {
  type    = string
  default = "teaf3tier" # يُستخدم لتسمية بقية الموارد (خليه كما هو أو غيّره لو تبغى)
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_ssh_pubkey" {
  type      = string
  sensitive = true
}

# IPs ثابتة للـ NICs:
variable "fe_ip" {
  type    = string
  default = "10.0.1.4"
}
variable "api_ip" {
  type    = string
  default = "10.0.2.4"
}
variable "ops_ip" {
  type    = string
  default = "10.0.4.4"
}

# المنافذ ومسارات الـ health
variable "frontend_port" {
  type    = number
  default = 80
}
variable "backend_port" {
  type    = number
  default = 8080
}
variable "frontend_probe_path" {
  type    = string
  default = "/health"
}
variable "backend_probe_path" {
  type    = string
  default = "/health" # غيّرها لـ /actuator/health إذا APIك كذا
}

# حجم الـ VM
variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

# SQL
variable "sql_admin_user" {
  type    = string
  default = "sqladminuser"
}
variable "sql_admin_password" {
  type      = string
  sensitive = true
}
variable "sql_sku_name" {
  type    = string
  default = "S0"
}

# Alerts
variable "alert_email" {
  type    = string
  default = ""
}

# Tags
variable "tags" {
  type = map(string)
  default = {
    project = "devops-project2"
    tier    = "3tier"
  }
}

