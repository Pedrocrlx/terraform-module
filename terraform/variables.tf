variable "namespace" {
  default = "notes-app"
}

variable "db_password" {
  description = "A password da base de dados"
  type        = string
  sensitive   = true
}