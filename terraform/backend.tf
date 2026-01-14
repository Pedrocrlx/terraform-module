resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend-service"
    namespace = kubernetes_namespace.ns.metadata[0].name
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

resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.ns.metadata[0].name
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
          image             = "notes-backend:1.0" # A TUA VERSÃO MAIS RECENTE
          image_pull_policy = "Never"            # CRUCIAL PARA MINIKUBE
          
          port {
            container_port = 8000
          }

          # Variáveis de Ambiente
          env {
            name  = "DB_HOST"
            # Monta o nome completo automaticamente: db-service.notes-app.svc.cluster.local
            value = "${kubernetes_service.db.metadata[0].name}.${kubernetes_namespace.ns.metadata[0].name}.svc.cluster.local"
          }
          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_secret.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
        }
      }
    }
  }
}