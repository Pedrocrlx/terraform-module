resource "kubernetes_secret_v1" "db_secret" {
  metadata {
    name      = "db-secret"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }
  data = {
    POSTGRES_DB       = "app_db"
    POSTGRES_USER     = "postgres"
    POSTGRES_PASSWORD = var.db_password
  }
}

resource "kubernetes_service_v1" "db" {
  metadata {
    name      = "db-service"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }
  spec {
    selector = {
      app = "database"
    }
    port {
      port        = 5432
      target_port = 5432
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_stateful_set_v1" "db" {
  metadata {
    name      = "db"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }
  spec {
    service_name = "db-service"
    replicas     = 1
    selector {
      match_labels = {
        app = "database"
      }
    }
    template {
      metadata {
        labels = {
          app = "database"
        }
      }
      spec {
        container {
          name  = "postgres"
          image = "postgres:17"
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.db_secret.metadata[0].name
            }
          }
          volume_mount {
            name       = "db-data"
            mount_path = "/var/lib/postgresql/data"
          }
        }
        volume {
          name = "db-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.db_pvc.metadata[0].name
          }
        }
      }
    }
  }
}