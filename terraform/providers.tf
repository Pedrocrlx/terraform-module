terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config" # Path to kubeconfig file
  config_context = "minikube"       # Context name for Minikube
}