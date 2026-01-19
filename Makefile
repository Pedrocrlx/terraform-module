# Variables
TERRAFORM_DIR := terraform
SCRIPTS_DIR := scripts
PROFILE := terraform-k8s-cluster

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
	@cd $(TERRAFORM_DIR) && terraform apply -auto-approve

clean: ## Destroy Terraform infrastructure
	@echo "Destroying infrastructure..."
	@cd $(TERRAFORM_DIR) && terraform destroy -auto-approve

forward: ## Forward ports (Direct Access - bypasses Ingress/TLS). Use for debugging.
	@echo "Forwarding ports (Direct Pod Access)..."
	@echo "Frontend: http://localhost:3000"
	@echo "Backend:  http://localhost:8000"
	@trap 'kill %1 %2 %3' SIGINT; \
	kubectl port-forward svc/frontend 3000:3000 >/dev/null 2>&1 & \
	kubectl port-forward svc/backend 8000:8000 >/dev/null 2>&1 & \
	kubectl port-forward svc/postgres 5432:5432 >/dev/null 2>&1 & \
	wait

hosts: ## Configure /etc/hosts (Requires sudo)
	@echo "Getting Minikube IP..."
	$(eval IP := $(shell minikube -p $(PROFILE) ip))
	@if [ -z "$(IP)" ]; then echo "Error: Minikube is not running or IP not found"; exit 1; fi
	@echo "Configuring /etc/hosts with IP $(IP) (Requires sudo password)..."
	@chmod +x scripts/hosts.sh
	@sudo ./scripts/hosts.sh $(IP)

ingress-info: ## Show Ingress Access Info (Use this for HTTPS/TLS)
	@echo "--- Ingress Access (HTTPS) ---"
	@echo "Cluster IP: $$(minikube -p $(PROFILE) ip)"
	@echo "Hosts defined in Ingress: frontend.local, backend.local"
	@echo ""
	@echo "To setup automatically, run: make hosts"
	@echo "Then open in browser: https://frontend.local"