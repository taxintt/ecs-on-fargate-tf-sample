.PHONY: plan
plan: ## run terraform plan
	terraform plan -var-file ./vars/dev.tfvars

.PHONY: apply
apply: ## run terraform apply
	terraform apply -var-file ./vars/dev.tfvars

.PHONY: destroy
destroy: ## run terraform destroy
	terraform destroy -var-file ./vars/dev.tfvars

.PHONY: init
init: ## run terraform init
	terraform init

.PHONY: format
format: ## run terraform fmt
	terraform fmt --recursive