# -----------------------------
# Backend environment variables
# -----------------------------

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS (comma-separated)"
  type        = string
  default     = "135.225.92.111"
}

variable "db_driver" {
  description = "Database driver class name"
  type        = string
  default     = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
}

variable "db_host" {
  description = "Database hostname or private endpoint DNS name"
  type        = string
  default     = "burgerbuilder-sqlserver.privatelink.database.windows.net"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "burgerbuilder-db"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "sqladminuser"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "StrongPassword123!"
}

variable "db_port" {
  description = "Database port"
  type        = string
  default     = "1433"
}

variable "server_port" {
  description = "Port on which the backend server listens"
  type        = string
  default     = "8080"
}

variable "aca_static_ip" {
  description = "The static internal IP address of the Azure Container Apps Environment"
  type        = string
  default     = "10.20.1.30" # Replace with your ACA environment's internal IP
}

variable "spring_profiles_active" {
  description = "Spring profile to use (e.g., dev, prod)"
  type        = string
  default     = "azure"
}
variable "vite_api_base_url" {
  description = "Base URL for the frontend to call backend APIs (used by Vite build)"
  type        = string
  default     = "https://burgerbuilder-backend.internal.azurecontainerapps.io"
}

variable "frontend_image" {
  description = "Frontend Docker image"
  default     = "burgerbuilderacr.azurecr.io/burgerbuilder-frontend:latest"
}

variable "backend_image" {
  description = "Backend Docker image"
  default     = "burgerbuilderacr.azurecr.io/burgerbuilder-backend:latest"
}
