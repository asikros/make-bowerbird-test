# Constants
.DEFAULT_GOAL := help

#Targets
.PHONY: check
check: ## Runs all repository tests
check: private_test

.PHONY: clean
clean: ## Deletes all files created by Make
clean: private_clean

.PHONY: test
test: ## Runs all repository tests (alias for check)
test: private_test

# Includes
include make/private.mk
