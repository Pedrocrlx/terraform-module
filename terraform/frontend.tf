resource "kubernetes_service_v1" "frontend" {
  metadata {
    name      = "frontend-service"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }
  spec {
    selector = {
      app = "frontend"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_deployment_v1" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }
      spec {
        container {
          name              = "frontend"
          image             = "notes-frontend:1.0"
          image_pull_policy = "Never"
          port {
            container_port = 80
          }
        }
      }
    }
  }

  depends_on = [null_resource.docker_images]
}