resource "kubernetes_secret" "db_secret" {
  metadata {
    name      = "db-secret"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  data = {
    POSTGRES_DB       = "app_db"
    POSTGRES_USER     = "postgres"
    POSTGRES_PASSWORD = var.db_password
  }
}

resource "kubernetes_service" "db" {
  metadata {
    name      = "db-service"
    namespace = kubernetes_namespace.ns.metadata[0].name
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

resource "kubernetes_stateful_set" "db" {
  metadata {
    name      = "db"
    namespace = kubernetes_namespace.ns.metadata[0].name
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
              name = kubernetes_secret.db_secret.metadata[0].name
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
            claim_name = kubernetes_persistent_volume_claim.db_pvc.metadata[0].name
          }
        }
      }
    }
  }
}