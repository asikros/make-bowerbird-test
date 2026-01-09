WORKDIR_TEST ?= $(error ERROR: Undefined variable WORKDIR_TEST)

# BOWERBIRD_MOCK_SHELL is defined in bowerbird.mk and points to scripts/mock-shell.sh
# This script extracts the last argument ($#) as the command and appends it to BOWERBIRD_MOCK_RESULTS.
# This handles any .SHELLFLAGS configuration:
#   .SHELLFLAGS := -c        → args: -c "cmd"       → last arg is cmd ✓
#   .SHELLFLAGS := -e -u -c  → args: -e -u -c "cmd" → last arg is cmd ✓
#   .SHELLFLAGS := -xc       → args: -xc "cmd"      → last arg is cmd ✓

# KEY MECHANISM: Target-specific SHELL override
# When BOWERBIRD_MOCK_RESULTS is set (by test runner), all targets use mock shell
# This ONLY affects recipe execution, not $(shell) calls during parsing
# The inline shell captures the command and appends it to BOWERBIRD_MOCK_RESULTS
# Format: sh -c 'eval "CMD=\"${$#}\""; echo "$CMD" >> "$RESULTS"' sh
ifdef BOWERBIRD_MOCK_RESULTS
%: SHELL = sh -c 'eval "COMMAND=\"\$${$$\#}\""; echo "$$COMMAND" >> "$${BOWERBIRD_MOCK_RESULTS:?BOWERBIRD_MOCK_RESULTS must be set}"' sh
endif

# bowerbird::test::add-mock-test
#
#   Creates a test target that runs another target with mock shell
#   and compares captured commands against expected output.
#
#   Args:
#       $1: Test name (e.g., test-mock-clean)
#       $2: Target to test (e.g., clean)
#       $3: Expected output variable name (define block with expected commands)
#       $4: Optional extra make arguments (e.g., VAR=value)
#
#   Example:
#       define expected-clean
#       rm -rf /tmp/build
#       echo Clean complete
#       endef
#
#       $(call bowerbird::test::add-mock-test,\
#           test-mock-clean,\
#           clean,\
#           expected-clean,)
#
define bowerbird::test::add-mock-test
$(eval $(call __bowerbird::test::add-mock-test-impl,$(strip $1),$(strip $2),$(strip $3),$(strip $4)))
endef


# Private implementation (called via $(eval) by bowerbird::test::add-mock-test)
define __bowerbird::test::add-mock-test-impl
# Test target - generates expected/results and compares
.PHONY: $1
$1: SHELL = /bin/sh
$1:
	@mkdir -p $$(dir $$(WORKDIR_TEST)/$1/.expected)
	@$(if $(value $3),printf '%b\n' '$(subst $(BOWERBIRD_NEWLINE),\n,$(value $3))',true) > $$(WORKDIR_TEST)/$1/.expected
	@mkdir -p $$(dir $$(WORKDIR_TEST)/$1/.results)
	@rm -f $$(WORKDIR_TEST)/$1/.results
	$$(MAKE) BOWERBIRD_MOCK_RESULTS=$$(WORKDIR_TEST)/$1/.results $4 $2
	@touch $$(WORKDIR_TEST)/$1/.results
	@diff -u $$(WORKDIR_TEST)/$1/.expected $$(WORKDIR_TEST)/$1/.results || (>&2 echo "ERROR: Content mismatch for $1" && exit 1)
endef
