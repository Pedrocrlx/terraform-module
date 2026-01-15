resource "kubernetes_persistent_volume_claim_v1" "db_pvc" {
  metadata {
    name      = "db-data"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
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