WORKDIR_TEST ?= $(error ERROR: Undefined variable WORKDIR_TEST)

# Mock Shell Implementation
#
# When BOWERBIRD_MOCK_RESULTS is set, a mock shell is activated that captures
# shell commands from recipe execution instead of running them. Captured commands
# are written to the file specified by BOWERBIRD_MOCK_RESULTS.
#
# The mock shell is implemented as a bash script file created automatically as
# a prerequisite before tests run. This approach works reliably across platforms
# and handles parallel test execution safely.
#
ifdef BOWERBIRD_MOCK_RESULTS
export __BOWERBIRD_SHELL := $(SHELL)
export __BOWERBIRD_SHELLFLAGS = $(value .SHELLFLAGS)
# Export __BOWERBIRD_MOCK_SHOW_SHELL only if set (for optional SHELL/SHELLFLAGS capture)
ifneq ($(origin __BOWERBIRD_MOCK_SHOW_SHELL),undefined)
export __BOWERBIRD_MOCK_SHOW_SHELL
endif
__BOWERBIRD_MOCK_SHELL_FILE = $(dir $(BOWERBIRD_MOCK_RESULTS))mock-shell.bash
%: SHELL = /bin/bash $(__BOWERBIRD_MOCK_SHELL_FILE)
endif

# Pattern rule to create mock shell script files (atomic write for parallel safety)
%mock-shell.bash:
	@mkdir -p $(dir $@)
	@printf '%s\n' '#!/bin/bash' > $@.tmp
	@printf '%s\n' 'for __c; do :; done' >> $@.tmp
	@printf '%s\n' '__c_normalized=$$(printf "%s" "$$__c" | tr -d '"'"'\'"'"' | tr -s "[:space:]" " " | sed "s/^ //" | sed "s/ $$//")'  >> $@.tmp
	@printf '%s\n' 'if [ "$${__BOWERBIRD_MOCK_SHOW_SHELL+set}" = "set" ]; then' >> $@.tmp
	@printf '%s\n' '  printf "%s %s %s\n" "$$__BOWERBIRD_SHELL" "$$__BOWERBIRD_SHELLFLAGS" "$$__c_normalized" >>"$$BOWERBIRD_MOCK_RESULTS"' >> $@.tmp
	@printf '%s\n' 'else' >> $@.tmp
	@printf '%s\n' '  printf "%s\n" "$$__c_normalized" >>"$$BOWERBIRD_MOCK_RESULTS"' >> $@.tmp
	@printf '%s\n' 'fi' >> $@.tmp
	@mv $@.tmp $@

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
$1: $$(WORKDIR_TEST)/$1/mock-shell.bash
$1:
	@mkdir -p $$(WORKDIR_TEST)/$1
	@: > $$(WORKDIR_TEST)/$1/results
	$$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$$(WORKDIR_TEST)/$1/results $4 $2
	$$(call bowerbird::test::compare-file-content-from-var,$$(WORKDIR_TEST)/$1/results,$3)
endef
