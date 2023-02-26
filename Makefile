.PHONY: plan
plan: ## run terraform plan
	$(MAKE) -C environment/dev plan

.PHONY: apply
apply: ## run terraform apply
	$(MAKE) -C environment/dev apply

.PHONY: destroy
destroy: ## run terraform destroy
	$(MAKE) -C environment/dev destroy

.PHONY: init
init: ## run terraform init
	$(MAKE) -C environment/dev init

.PHONY: format
format: ## run terraform fmt
	$(MAKE) -C environment/dev format