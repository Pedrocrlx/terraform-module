resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = var.namespace
  }
  depends_on = [
    null_resource.build_and_load
  ]
}

