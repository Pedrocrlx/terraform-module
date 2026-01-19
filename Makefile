# Variables
TERRAFORM_DIR := terraform
SCRIPTS_DIR := scripts
PROFILE := terraform-k8s-cluster

SHELL := /bin/bash
.PHONY: all help install init up clean forward ingress-info hosts

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Check dependencies (terraform, docker, etc.)
	@echo "Checking dependencies..."
	@command -v terraform >/dev/null 2>&1 || { echo >&2 "Terraform is not installed. Aborting."; exit 1; }
	@command -v minikube >/dev/null 2>&1 || { echo >&2 "Minikube is not installed. Aborting."; exit 1; }
	@command -v docker >/dev/null 2>&1 || { echo >&2 "Docker is not installed. Aborting."; exit 1; }
	@echo "All dependencies check out."

init: ## Initialize Terraform
	@echo "Initializing Terraform..."
	@cd $(TERRAFORM_DIR) && terraform init

up: ## Apply Terraform configuration (Builds infra + images)
	@echo "Applying infrastructure..."
	@cd $(TERRAFORM_DIR) && terraform plan -out=k8s.plan
	@cd $(TERRAFORM_DIR) && terraform apply k8s.plan

clean: ## Destroy Terraform infrastructure
	@echo "Destroying infrastructure..."
	@cd $(TERRAFORM_DIR) && terraform destroy -auto-approve

forward: ## Forward ports (Direct Access - bypasses Ingress/TLS). Use for debugging.
	@echo "Forwarding ports (Direct Pod Access)..."
	@echo "Frontend: http://localhost:3000"
	@echo "Backend:  http://localhost:8000"
	@trap 'kill %1 %2 %3' SIGINT; \
	kubectl port-forward svc/frontend-service 3000:3000 >/dev/null 2>&1 & \
	kubectl port-forward svc/backend-service 8000:8000 >/dev/null 2>&1 & \
	kubectl port-forward svc/db-service 5432:5432 >/dev/null 2>&1 & \
	wait

hosts: ## Configure /etc/hosts to point to localhost (Requires sudo)
	@echo "Configuring /etc/hosts for notes-app.local..."
	@echo "127.0.0.1 notes-app.local" | sudo tee -a /etc/hosts > /dev/null || true
	@sudo sed -i '/192.168.49.2.*notes-app.local/d' /etc/hosts
	@echo "✓ /etc/hosts configured"

ingress-forward: ## Forward Ingress ports for HTTPS access (Keep running)
	@echo "=== Ingress Port Forwarding ==="
	@echo "This enables HTTPS access at: https://notes-app.local:8443"
	@echo "Make sure /etc/hosts is configured (run 'make hosts' first)"
	@echo "Press Ctrl+C to stop"
	@echo ""
	@kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8443:443

ingress-info: ## Show Ingress Access Info
	@echo "--- Ingress HTTPS Access ---"
	@echo ""
	@echo "Step 1: Configure /etc/hosts"
	@echo "  $$ make hosts"
	@echo ""
	@echo "Step 2: Start Ingress port forwarding (in separate terminal or background)"
	@echo "  $$ make ingress-forward"
	@echo ""
	@echo "Step 3: Open browser and access:"
	@echo "  🌐 https://notes-app.local:8443"
	@echo ""
	@echo "Note: You'll need to accept the self-signed certificate warning"