help:       
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

## --------- Application --------
install: ## Prepare the environment (install Minikube, build and load images, create secrets)
	@echo " Setting up the environment..."
	chmod +x scripts/install.sh
	scripts/install.sh

init: ## Initialize the environment (Terraform init)
	@echo "Initializing the environment..."
	chmod +x scripts/init.sh
	scripts/init.sh	

apply: ## Apply the infrastructure (Terraform apply)
	@echo " Applying the infrastructure..."
	chmod +x scripts/apply.sh
	scripts/apply.sh

view: ## Port-forwarding to access services locally (backend:8000, frontend:3000)
	@echo " Port-forwarding to access services locally..."
	kubectl port-forward svc/backend-service 8000:8000 & kubectl port-forward svc/frontend-service 3000:3000

## --------- Clean Up --------
destroy: ## Destroy the environment (Terraform destroy)
	@echo " Destroying the environment..."
	chmod +x scripts/destroy.sh
	scripts/destroy.sh

## --------- Testing --------
test: ## Check the status of all pods in the 'notes-app' namespace
	@echo " Checking the status of all pods..."
	chmod +x scripts/test.sh
	scripts/test.sh