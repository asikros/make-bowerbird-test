WORKDIR_TEST ?= $(error ERROR: Undefined variable WORKDIR_TEST)

# Mock shell script content
# The script receives the command as $1 and appends it to BOWERBIRD_MOCK_RESULTS
define bowerbird-mock-shell-rendering
#!/bin/sh
echo "$$1" >> "$${BOWERBIRD_MOCK_RESULTS:?BOWERBIRD_MOCK_RESULTS must be set}"
endef

# Mock shell script path and source tracking
BOWERBIRD_MOCK_SHELL := $(WORKDIR_TEST)/.mock-shell.sh
BOWERBIRD_MOCK_MK := $(lastword $(MAKEFILE_LIST))

# Create mock shell script when needed
# Use explicit SHELL=/bin/sh to avoid chicken-and-egg with pattern rule
# Depends on this makefile to regenerate if definition changes
#
# IMPORTANT: The script extracts the last argument ($#) as the command.
# This handles any .SHELLFLAGS configuration:
#   .SHELLFLAGS := -c        → args: -c "cmd"       → last arg is cmd ✓
#   .SHELLFLAGS := -e -u -c  → args: -e -u -c "cmd" → last arg is cmd ✓
#   .SHELLFLAGS := -xc       → args: -xc "cmd"      → last arg is cmd ✓
$(BOWERBIRD_MOCK_SHELL): SHELL = /bin/sh
$(BOWERBIRD_MOCK_SHELL): $(BOWERBIRD_MOCK_MK)
	@mkdir -p $(dir $@)
	@{ printf '%s\n' \
		'#!/bin/sh' \
		'# Extract command (always last argument after SHELLFLAGS)' \
		'eval "COMMAND=\"\$${$$#}\""' \
		'echo "$$COMMAND" >> "$${BOWERBIRD_MOCK_RESULTS:?BOWERBIRD_MOCK_RESULTS must be set}"' \
		> $@.tmp && \
	chmod +x $@.tmp && \
	xattr -d com.apple.provenance $@.tmp 2>/dev/null || true; } && \
	mv $@.tmp $@

# KEY MECHANISM: Target-specific SHELL override
# When BOWERBIRD_MOCK_RESULTS is set (by test runner), all targets use mock shell
# This ONLY affects recipe execution, not $(shell) calls during parsing
ifdef BOWERBIRD_MOCK_RESULTS
%: SHELL = $(BOWERBIRD_MOCK_SHELL)
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
# Expected file target - generates expected output
$$(WORKDIR_TEST)/$1/.expected: $$(BOWERBIRD_MOCK_MK)
	@mkdir -p $$(dir $$@)
	@$(if $(value $3),printf '%b\n' '$(subst $(BOWERBIRD_NEWLINE),\n,$(value $3))',true) > $$@

# Results file target - generates actual output
$$(WORKDIR_TEST)/$1/.results: $$(BOWERBIRD_MOCK_SHELL)
	@mkdir -p $$(dir $$@)
	@rm -f $$@
	$$(MAKE) BOWERBIRD_MOCK_RESULTS=$$@ $4 $2
	@touch $$@

# Test target - depends on both files and compares
.PHONY: $1
$1: SHELL = /bin/sh
$1: $$(WORKDIR_TEST)/$1/.expected $$(WORKDIR_TEST)/$1/.results
	@diff -u $$^ || (>&2 echo "ERROR: Content mismatch for $1" && exit 1)
endef
