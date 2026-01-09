_PATH := $(dir $(lastword $(MAKEFILE_LIST)))
# Use generated mock shells in /tmp
# The wrapper invokes the real mock shell through /bin/sh to bypass macOS quarantine
BOWERBIRD_MOCK_SHELL_REAL := /tmp/bowerbird-mock-shell-real-$(USER).sh
BOWERBIRD_MOCK_SHELL := /tmp/bowerbird-mock-shell-wrapper-$(USER).sh
include $(_PATH)/src/bowerbird-test/bowerbird-constants.mk
include $(_PATH)/src/bowerbird-test/bowerbird-compare.mk
include $(_PATH)/src/bowerbird-test/bowerbird-find.mk
include $(_PATH)/src/bowerbird-test/bowerbird-test-runner.mk
include $(_PATH)/src/bowerbird-test/bowerbird-mock.mk