#!/bin/bash

echo "1. Terraform Apply"
cd terraform

terraform apply -target=minikube_cluster.docker -auto-approve

echo "2. Construir e Carregar Imagens..."

cd .. 

# Build
docker build -t notes-backend:1.0 -f ./backend/Dockefile ./backend
docker build -t notes-frontend:1.0 -f ./frontend/Dockefile ./frontend

# Load images
minikube image load notes-backend:1.0 -p terraform-k8s-cluster
minikube image load notes-frontend:1.0 -p terraform-k8s-cluster

cd terraform

terraform plan -out k8s.plan

terraform apply k8s.plan 