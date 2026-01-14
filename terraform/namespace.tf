resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

variable "db_password" {
  default = "postgres" 
}