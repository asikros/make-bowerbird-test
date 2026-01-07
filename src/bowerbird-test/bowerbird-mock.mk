WORKDIR_TEST ?= $(error ERROR: Undefined variable WORKDIR_TEST)

# Mock shell script rendering
define bowerbird-mock-shell-rendering
#!/bin/sh
set -eu

RESULTS_FILE="$${BOWERBIRD_MOCK_RESULTS:?BOWERBIRD_MOCK_RESULTS must be set}"
mkdir -p "$$(dirname "$${RESULTS_FILE}")"
echo "$$1" >> "$${RESULTS_FILE}"
endef

# Target to create the mock shell script
BOWERBIRD_MOCK_SHELL := $(WORKDIR_TEST)/.mock-shell.sh
BOWERBIRD_MOCK.MK := $(lastword $(MAKEFILE_LIST))

$(BOWERBIRD_MOCK_SHELL): $(BOWERBIRD_MOCK.MK)
	@mkdir -p $(dir $@)
	$(file >$@,$(bowerbird-mock-shell-rendering))
	@chmod +x "$@"

# Automatic SHELL replacement when BOWERBIRD_MOCK_RESULTS is set
ifdef BOWERBIRD_MOCK_RESULTS
    SHELL := $(BOWERBIRD_MOCK_SHELL)
    .SHELLFLAGS :=
endif

# bowerbird::test::add-mock-test-implementation
#
#   Internal implementation that generates the test target.
#
#   Args:
#       $1: Test name
#       $2: Target to test
#       $3: Expected output string
#       $4: Optional command-line variables (e.g., VAR1=value VAR2=value)
#
define bowerbird::test::add-mock-test-implementation
$1: __MOCK_RESULTS = $$(WORKDIR_TEST)/$1/.results
$1: $$(BOWERBIRD_MOCK_SHELL)
	$$(MAKE) BOWERBIRD_MOCK_RESULTS=$$(__MOCK_RESULTS) $4 $2
	@$$(call bowerbird::test::compare-file-content,$$(__MOCK_RESULTS),$3)
endef

# bowerbird::test::add-mock-test
#
#   Adds a mock test target with automatic boilerplate.
#
#   Args:
#       $1: Test name
#       $2: Target to test
#       $3: Expected output string
#       $4: Optional command-line variables (e.g., VAR1=value VAR2=value)
#
#   Example:
#       $(call bowerbird::test::add-mock-test,\
#           test-mock-clean,clean,$(mock-clean-expected))
#       $(call bowerbird::test::add-mock-test,\
#           test-mock-git-dep,myrepo/.,$(expected),\
#           __TEST_MOCK_GIT_DEPENDENCY=)
#
define bowerbird::test::add-mock-test
$(eval $(call bowerbird::test::add-mock-test-implementation,$1,$2,$3,$4))
endef
