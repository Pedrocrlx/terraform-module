resource "kubernetes_service_v1" "backend" {
  metadata {
    name      = "backend-service"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }
  spec {
    selector = {
      app = "backend"
    }
    port {
      port        = 8000
      target_port = 8000
    }
  }
}

resource "kubernetes_deployment_v1" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "backend"
        }
      }
      spec {
        container {
          name              = "backend"
          image             = "notes-backend:1.0"
          image_pull_policy = "IfNotPresent"            
          
          port {
            container_port = 8000
          }

          
          env {
            name  = "DB_HOST"
            value = "${kubernetes_service_v1.db.metadata[0].name}"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.db_secret.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
        }
        dns_config {
          option {
          name  = "ndots"
          value = "2"
        }
}
      }
    }
  }

  depends_on = [null_resource.docker_images]
}