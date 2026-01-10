WORKDIR_TEST ?= $(error ERROR: Undefined variable WORKDIR_TEST)

# Mock Shell Implementation
#
# When BOWERBIRD_MOCK_RESULTS is set, a mock shell is activated for all targets via a
# pattern rule that sets a target-specific SHELL variable. The mock shell captures
# commands instead of executing them. It is defined as an inline string to avoid
# macOS Gatekeeper quarantine issues with external script files.
#
# The mock shell extracts the last argument ($#) as the command and appends it to
# BOWERBIRD_MOCK_RESULTS. This works with any .SHELLFLAGS configuration:
#   .SHELLFLAGS := -c        → args: -c "cmd"       → last arg is cmd ✓
#   .SHELLFLAGS := -e -u -c  → args: -e -u -c "cmd" → last arg is cmd ✓
#   .SHELLFLAGS := -xc       → args: -xc "cmd"      → last arg is cmd ✓
#
# Note: This ONLY affects recipe execution in targets, not $(shell) calls during parsing.
#
ifdef BOWERBIRD_MOCK_RESULTS
%: SHELL = sh -c 'eval "COMMAND=\"\$${$$\#}\""; echo "$$COMMAND" >> "$${BOWERBIRD_MOCK_RESULTS:?BOWERBIRD_MOCK_RESULTS must be set}"' sh
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
define bowerbird::test::add-mock-test # test-name, target, expected-output, extra-args
$(eval $(call bowerbird::test::__add-mock-test-impl,$(strip $1),$(strip $2),$(strip $3),$(strip $4)))
endef


# Private implementation (called via $(eval) by bowerbird::test::add-mock-test)
define bowerbird::test::__add-mock-test-impl # test-name, target, expected-output, extra-args
# Test target - runs target with mock shell and compares captured commands
.PHONY: $1
$1: SHELL = /bin/sh
$1:
	@mkdir -p $$(dir $$(WORKDIR_TEST)/$1/.results)
	@: > $$(WORKDIR_TEST)/$1/.results
	$$(MAKE) BOWERBIRD_MOCK_RESULTS=$$(WORKDIR_TEST)/$1/.results $4 $2
	@touch $$(WORKDIR_TEST)/$1/.results
	$$(call bowerbird::test::compare-file-content-from-var,$$(WORKDIR_TEST)/$1/.results,$3)
endef
