resource "null_resource" "docker_images" {
  triggers = {
    backend  = join("", [for f in fileset("${path.module}/../backend", "**") : filesha1("${path.module}/../backend/${f}")])
    frontend = join("", [for f in fileset("${path.module}/../frontend", "**") : filesha1("${path.module}/../frontend/${f}")])
  }

  provisioner "local-exec" {
    command = <<EOT
      docker build -t notes-backend:1.0 -f ${path.module}/../backend/Dockerfile ${path.module}/../backend
      docker build -t notes-frontend:1.0 -f ${path.module}/../frontend/Dockerfile ${path.module}/../frontend
      minikube image load notes-backend:1.0 notes-frontend:1.0 -p terraform-k8s-cluster
    EOT
  }

  depends_on = [minikube_cluster.docker]
}
