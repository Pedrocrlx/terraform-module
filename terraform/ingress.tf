resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "app-ingress"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }
  spec {
    ingress_class_name = "nginx"
    
    tls {
      hosts = ["frontend.local", "backend.local"]
      secret_name = kubernetes_secret_v1.tls_secret.metadata[0].name
    }

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.frontend.metadata[0].name
              port {
                number = 3000
              }
            }
          }
        }
        path {
          path      = "/notes"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.backend.metadata[0].name
              port {
                number = 8000
              }
            }
          }
        }
      }
    }
  }
}