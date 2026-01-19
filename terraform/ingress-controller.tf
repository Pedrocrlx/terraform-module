resource "null_resource" "patch_ingress_controller" {
  # This resource patches the ingress-nginx-controller service
  # from NodePort to LoadBalancer to enable direct access on ports 80/443
  
  provisioner "local-exec" {
    command = <<-EOT
      kubectl patch svc ingress-nginx-controller \
        -n ingress-nginx \
        -p '{"spec":{"type":"LoadBalancer"}}'
    EOT
  }

  # Start the minikube tunnel automatically
  provisioner "local-exec" {
    command = "chmod +x ${path.module}/../scripts/tunnel-start.sh && ${path.module}/../scripts/tunnel-start.sh"
  }

  # Stop tunnel on destroy
  provisioner "local-exec" {
    when    = destroy
    command = "chmod +x ${path.module}/../scripts/tunnel-stop.sh && ${path.module}/../scripts/tunnel-stop.sh || true"
  }

  # Ensure this runs after the cluster and ingress addon are ready
  depends_on = [
    minikube_cluster.docker,
    kubernetes_ingress_v1.ingress
  ]
  
  # Trigger re-patching if cluster changes
  triggers = {
    cluster_id = minikube_cluster.docker.id
  }
}

# Wait for the LoadBalancer to be assigned
resource "null_resource" "wait_for_loadbalancer" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for LoadBalancer IP assignment..."
      for i in {1..30}; do
        EXTERNAL_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
        if [ ! -z "$EXTERNAL_IP" ]; then
          echo "LoadBalancer IP assigned: $EXTERNAL_IP"
          exit 0
        fi
        echo "Attempt $i/30: Waiting for LoadBalancer IP..."
        sleep 2
      done
      echo "Warning: LoadBalancer IP not assigned after 60 seconds"
      exit 0
    EOT
  }

  depends_on = [null_resource.patch_ingress_controller]
}

# Output the LoadBalancer IP for verification
data "kubernetes_service_v1" "ingress_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [null_resource.wait_for_loadbalancer]
}

output "ingress_loadbalancer_ip" {
  value       = try(data.kubernetes_service_v1.ingress_controller.status[0].load_balancer[0].ingress[0].ip, "Pending...")
  description = "LoadBalancer IP for Ingress Controller"
}
