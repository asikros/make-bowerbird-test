WORKDIR_TEST ?= $(error ERROR: Undefined variable WORKDIR_TEST)

# Path to static mock shell script
__BOWERBIRD_MOCK_SHELL_SCRIPT := $(dir $(lastword $(MAKEFILE_LIST)))../../scripts/mock-shell.bash

# Mock Shell Implementation
#
# When BOWERBIRD_MOCK_RESULTS is set, a mock shell is activated that captures
# shell commands from recipe execution instead of running them. Captured commands
# are written to the file specified by BOWERBIRD_MOCK_RESULTS.
#
# The mock shell is a static bash script (scripts/mock-shell.bash) that works
# reliably across platforms and handles parallel test execution safely.
#
# Line continuations in recipes are normalized by removing backslashes and
# collapsing whitespace, ensuring consistent behavior across GNU Make versions
# and platforms (macOS vs Ubuntu).
#
ifdef BOWERBIRD_MOCK_RESULTS
export __BOWERBIRD_SHELL := $(SHELL)
export __BOWERBIRD_SHELLFLAGS = $(value .SHELLFLAGS)
# Export __BOWERBIRD_MOCK_SHOW_SHELL only if set (for optional SHELL/SHELLFLAGS capture)
ifneq ($(origin __BOWERBIRD_MOCK_SHOW_SHELL),undefined)
export __BOWERBIRD_MOCK_SHOW_SHELL
endif
%: SHELL = /bin/bash $(__BOWERBIRD_MOCK_SHELL_SCRIPT)
endif

# bowerbird::test::add-mock-test, test-name, target, expected-output, extra-args
#
#   Creates a test target that runs another target with mock shell
#   and compares captured commands against expected output.
#
#   Args:
#       test-name: Test name (e.g., test-mock-clean)
#       target: Target to test (e.g., clean)
#       expected-output: Expected output variable name (define block with expected commands)
#       extra-args: Optional extra make arguments (e.g., VAR=value)
#
#   Example:
#       .PHONY: clean
#       clean:
#           @rm -rf /tmp/build
#           @echo "Clean complete"
#
#       define expected-clean
#       rm -rf /tmp/build
#       echo "Clean complete"
#       endef
#
#       $(call bowerbird::test::add-mock-test,\
#           test-mock-clean,\
#           clean,\
#           expected-clean,)
#
#   Note: By default only commands are captured. To also capture SHELL and SHELLFLAGS,
#         pass __BOWERBIRD_MOCK_SHOW_SHELL= in extra-args.
#
define bowerbird::test::add-mock-test # test-name, target, expected-output, extra-args
$(eval $(call bowerbird::test::__add-mock-test-impl,$(strip $1),$(strip $2),$(strip $3),$4))
endef


# Private implementation - do not call directly
define bowerbird::test::__add-mock-test-impl # test-name, target, expected-output, extra-args
.PHONY: $1
$1: SHELL = /bin/sh
$1:
	@mkdir -p $$(WORKDIR_TEST)/$1
	@: > $$(WORKDIR_TEST)/$1/results
	$$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$$(WORKDIR_TEST)/$1/results $4 $2
	$$(call bowerbird::test::compare-file-content-from-var,$$(WORKDIR_TEST)/$1/results,$3)
endef
