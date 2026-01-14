# Config
.SUFFIXES:
MAKEFLAGS += --jobs=8
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables
MAKEFLAGS += --warn-undefined-variables

# Constants
NAME := bowerbird-test
VERSION := $(shell git describe --always --dirty --broken 2> /dev/null)
WORKDIR_ROOT := $(CURDIR)/.make
WORKDIR_DEPS = $(WORKDIR_ROOT)/deps
WORKDIR_TEST = $(WORKDIR_ROOT)/test/$(NAME)/$(VERSION)

# Includes
include make/deps.mk
include bowerbird.mk

# Targets
.PHONY: private_clean
private_clean:
	@echo "INFO: Cleaning directories:"
	@$(if $(wildcard $(WORKDIR_DEPS)), rm -rfv $(WORKDIR_DEPS))
	@$(if $(wildcard $(WORKDIR_ROOT)), rm -rfv $(WORKDIR_ROOT))
	@$(if $(wildcard $(WORKDIR_TEST)), rm -rfv $(WORKDIR_TEST))
	@echo "INFO: Cleaning complete."
	@echo

$(call bowerbird::test::suite,private_test,test/bowerbird-test,test*.mk,test*)
