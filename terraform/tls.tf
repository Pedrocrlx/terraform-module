resource "tls_private_key" "pk" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.pk.private_key_pem

  subject {
    common_name  = "notes-app.local"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "local_file" "domain_crt" {
  content  = tls_self_signed_cert.cert.cert_pem
  filename = "${path.module}/../domain.crt"
}

resource "local_file" "domain_key" {
  content  = tls_private_key.pk.private_key_pem
  filename = "${path.module}/../domain.key"
}

resource "kubernetes_secret_v1" "tls_secret" {
  metadata {
    name      = "tls-secret"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.cert.cert_pem
    "tls.key" = tls_private_key.pk.private_key_pem
  }
}
