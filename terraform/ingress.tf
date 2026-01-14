resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "app-ingress"
    namespace = kubernetes_namespace.ns.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.frontend.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
        path {
          path      = "/notes"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.backend.metadata[0].name
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