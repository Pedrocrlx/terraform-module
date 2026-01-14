resource "kubernetes_persistent_volume_claim" "db_pvc" {
  metadata {
    name      = "db-data"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    # storage_class_name = "standard" # Opcional no minikube, ele assume default
  }
}