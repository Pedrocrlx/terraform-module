resource "null_resource" "docker_images" {
  triggers = {
    backend_code = join("", [for f in fileset("${path.module}/../backend", "**") : filesha1("${path.module}/../backend/${f}")])
    frontend_code = join("", [for f in fileset("${path.module}/../frontend", "**") : filesha1("${path.module}/../frontend/${f}")])
  }

  provisioner "local-exec" {
    command = <<EOT
      eval $(minikube -p terraform-k8s-cluster docker-env)
      docker build -t notes-backend:1.0 -f ${path.module}/../backend/Dockerfile ${path.module}/../backend
      docker build -t notes-frontend:1.0 -f ${path.module}/../frontend/Dockerfile ${path.module}/../frontend
    EOT
  }

  depends_on = [minikube_cluster.docker]
}
