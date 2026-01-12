WORKDIR_TEST ?= $(error ERROR: Undefined variable WORKDIR_TEST)

# Mock Shell Implementation
#
# When BOWERBIRD_MOCK_RESULTS is set, a mock shell is activated for all targets via a
# pattern rule that sets a target-specific SHELL variable. The mock shell captures
# shell commands instead of executing them, writing them to BOWERBIRD_MOCK_RESULTS.
# It is defined as an inline string to avoid macOS Gatekeeper quarantine issues.
#
# The mock shell uses bash to:
#   1. Export .SHELLFLAGS as __BOWERBIRD_SHELLFLAGS environment variable (to avoid quoting issues)
#   2. Extract the command using ${@: -1} (bash array slicing for last argument)
#   3. Write both __BOWERBIRD_SHELLFLAGS and the command to the results file
#
# This approach works reliably across macOS and Ubuntu by:
#   - Using environment variables to pass .SHELLFLAGS (no quoting/escaping needed)
#   - Using bash's simple array slicing syntax (no complex parameter expansion)
#   - Avoiding the `#` character which causes Make comment parsing issues
#
# Note: This ONLY affects recipe execution in targets, not $(shell) calls during parsing.
# See: development/NOTES-mock-shell-cross-platform.md for details on approaches tried
#
ifdef BOWERBIRD_MOCK_RESULTS
export __BOWERBIRD_SHELL := $(SHELL)
export __BOWERBIRD_SHELLFLAGS = $(value .SHELLFLAGS)
# Only export if explicitly set (not undefined)
ifneq ($(origin __BOWERBIRD_MOCK_SHOW_SHELL),undefined)
export __BOWERBIRD_MOCK_SHOW_SHELL
endif
%: SHELL = bash -c 'cmd="$${@: -1}"; if [ "$${__BOWERBIRD_MOCK_SHOW_SHELL+x}" ]; then printf "%s %s %s\\n" "$$__BOWERBIRD_SHELL" "$$__BOWERBIRD_SHELLFLAGS" "$$cmd" >>"$$BOWERBIRD_MOCK_RESULTS"; else printf "%s\\n" "$$cmd" >>"$$BOWERBIRD_MOCK_RESULTS"; fi' bash
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


# Private implementation (called via $(eval) by bowerbird::test::add-mock-test)
define bowerbird::test::__add-mock-test-impl # test-name, target, expected-output, extra-args
# Test target - runs target with mock shell and compares captured commands
.PHONY: $1
$1: SHELL = /bin/sh
$1:
	@mkdir -p $$(dir $$(WORKDIR_TEST)/$1/.results)
	@: > $$(WORKDIR_TEST)/$1/.results
	$$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$$(WORKDIR_TEST)/$1/.results $4 $2
	$$(call bowerbird::test::compare-file-content-from-var,$$(WORKDIR_TEST)/$1/.results,$3)
endef
