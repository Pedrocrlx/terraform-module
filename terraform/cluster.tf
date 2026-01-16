resource "minikube_cluster" "docker" {
  driver       = "docker"
  cluster_name = "terraform-k8s-cluster"
  
  # Recursos
  cpus   = 2
  memory = 4096
  
  # Addons
  addons = [
    "ingress",
    "default-storageclass",
    "storage-provisioner",
    "registry"
  ]
}

# Outputs para debugging (opcional)
output "cluster_ip" {
  value = minikube_cluster.docker.host
}