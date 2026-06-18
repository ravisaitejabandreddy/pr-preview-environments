.DEFAULT_GOAL := help
SHELL := /bin/bash

PR ?= 1
BRANCH ?= demo
SHA ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo dev)

.PHONY: help cluster-up cluster-down deploy teardown list demo

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

cluster-up: ## Create kind cluster + ingress-nginx
	./scripts/setup-cluster.sh

cluster-down: ## Delete the whole kind cluster
	kind delete cluster --name pr-preview

deploy: ## Deploy a preview env (PR=<n> BRANCH=<name>)
	./scripts/deploy-preview.sh $(PR) $(SHA) $(BRANCH)

teardown: ## Tear down a preview env (PR=<n>)
	./scripts/teardown-preview.sh $(PR)

list: ## List active preview namespaces
	@kubectl get ns -l app.kubernetes.io/managed-by=pr-preview

demo: cluster-up ## One-shot demo: cluster + two previews
	./scripts/deploy-preview.sh 1 $(SHA) feature-login
	./scripts/deploy-preview.sh 2 $(SHA) feature-checkout
	@echo ""
	@echo "Open these in your browser:"
	@echo "  http://pr-1.127-0-0-1.nip.io"
	@echo "  http://pr-2.127-0-0-1.nip.io"
