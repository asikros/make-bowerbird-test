# Dynamic Include-Based Test Runner
#
# This approach reduces orchestration overhead by generating include files on-the-fly.
# Make will automatically re-execute when included files are generated/updated.
#
# Key Insight: Use Make's automatic re-execution feature:
#   1. First pass: Generate .mk file with test rules
#   2. Make detects new include file and re-executes
#   3. Second pass: Run tests using generated rules
#
# Features:
#   - Fail-fast: Kills all running tests on first failure
#   - Fail-first: Runs previously failed tests first
#   - Undefined variable detection per test
#   - Colored output and detailed reporting
#   - Test isolation via recursive Make per test

WORKDIR_TEST ?= $(error ERROR: Undefined variable WORKDIR_TEST)

bowerbird-test.config.fail-exit-code = 0
bowerbird-test.config.fail-fast = 0
bowerbird-test.config.fail-first = 0
bowerbird-test.config.suppress-warnings = 0
bowerbird-test.config.file-patterns ?= test*.mk
bowerbird-test.config.target-patterns ?= test*

bowerbird-test.constant.generated-dir = $(WORKDIR_TEST)/.generated
bowerbird-test.constant.ext-fail = fail
bowerbird-test.constant.ext-log = log
bowerbird-test.constant.ext-pass = pass
bowerbird-test.constant.process-tag = __BOWERBIRD_TEST_PROCESS_TAG__=$(shell echo $$PPID)
bowerbird-test.constant.subdir-cache = .bowerbird
bowerbird-test.constant.undefined-variable-warning = warning: undefined variable
bowerbird-test.constant.workdir-logs = $(WORKDIR_TEST)/$(bowerbird-test.constant.subdir-cache)
bowerbird-test.constant.workdir-results = $(WORKDIR_TEST)/$(bowerbird-test.constant.subdir-cache)


# bowerbird::test::suite, target, path
#
#   Creates a target for running all the test targets discovered in the specified test
#	file path using dynamic include files to reduce orchestration overhead.
#
#   Generates a .mk file containing all test execution rules, then includes it.
#   Make automatically re-executes when the include file is created.
#
#   Features:
#   - Fail-fast support: Kills all tests on first failure
#   - Fail-first support: Runs previously failed tests first
#   - No recursive Make for orchestration (saves ~1s per suite)
#   - Test isolation maintained via recursive Make per test
#   - Undefined variable detection per test
#   - Colored output and detailed reporting
#   - Full dependency graph visible to Make
#
#   Args:
#       target: Name of the test suite target to create.
#       path: Starting directory name for the search.
#
#   Configuration:
#       bowerbird-test.config.fail-exit-code: Exit code for failed tests (default: 0)
#       bowerbird-test.config.fail-fast: Kill all tests on first failure (default: 0)
#       bowerbird-test.config.fail-first: Run failed tests first (default: 0)
#       bowerbird-test.config.suppress-warnings: Suppress warning messages (default: 0)
#       bowerbird-test.config.file-patterns: Space-separated list of file patterns (default: test*.mk)
#       bowerbird-test.config.target-patterns: Space-separated list of target patterns (default: test*)
#
#	Error:
#		Throws an error if target empty.
#		Throws an error if path empty.
#
#   Performance:
#   - ~2% faster than previous implementation (eliminates 5 orchestration calls)
#   - Generates ~256KB .mk file per suite (cached between runs)
#
#   Example:
#       $(call bowerbird::test::suite,test-target,test-dir)
# 		make test-target
#
define bowerbird::test::suite # target, path
$(eval $(call __bowerbird::test::suite-impl,$1,$2))
endef


# Generate the include file path for this suite
define __bowerbird::test::suite-generated-file # suite-name
$(bowerbird-test.constant.generated-dir)/$1.mk
endef


# Main implementation - generates the include file and loads it
define __bowerbird::test::suite-impl # target, path
# Validation
$$(if $1,,$$(error ERROR: missing target in '$$$$(call bowerbird::test::suite,<target>,<path>)'))
$$(if $2,,$$(error ERROR: missing path in '$$$$(call bowerbird::test::suite,$1,<path>)'))

# Define the generated file path
BOWERBIRD_GENERATED/$1 := $$(call __bowerbird::test::suite-generated-file,$1)

# Discover test files using configured patterns (supports multiple patterns)
ifndef BOWERBIRD_TEST/FILES/$1
export BOWERBIRD_TEST/FILES/$1 := $$(sort $$(foreach pattern,$$(bowerbird-test.config.file-patterns),$$(shell test -d $2 && find $$(abspath $2) -type f -name '$$(pattern)' 2>/dev/null)))
$$(if $$(BOWERBIRD_TEST/FILES/$1),,$$(if $$(filter 1,$$(bowerbird-test.config.suppress-warnings)),,$$(warning WARNING: No test files found in '$2' matching '$$(bowerbird-test.config.file-patterns)')))
endif

# Include test files to get targets
ifneq (,$$(BOWERBIRD_TEST/FILES/$1))
ifeq ($$(filter $$(MAKEFILE_LIST),$$(BOWERBIRD_TEST/FILES/$1)),)
include $$(BOWERBIRD_TEST/FILES/$1)
endif
endif

# Discover test targets using configured patterns (supports multiple patterns)
ifndef BOWERBIRD_TEST/TARGETS/$1
ifneq (,$$(BOWERBIRD_TEST/FILES/$1))
# First, get ALL targets from test files
export BOWERBIRD_TEST/TARGETS_ALL/$1 := $$(sort $$(shell cat $$(BOWERBIRD_TEST/FILES/$1) | \
    sed -e ':a' -e '/\\$$$$/N' -e 's/\\\n//g' -e 'ta' | \
    sed -n -e 's/^\([a-zA-Z0-9_-][a-zA-Z0-9_-]*\):.*/\1/p' 2>/dev/null))
# Convert shell-style patterns (test*) to Make-style patterns (test%) for filtering
BOWERBIRD_TEST/MAKE_PATTERNS/$1 := $$(subst *,%,$$(bowerbird-test.config.target-patterns))
# Then filter by configured patterns (supports wildcards like test% check%)
export BOWERBIRD_TEST/TARGETS/$1 := $$(sort $$(foreach pattern,$$(BOWERBIRD_TEST/MAKE_PATTERNS/$1),$$(filter $$(pattern),$$(BOWERBIRD_TEST/TARGETS_ALL/$1))))
else
export BOWERBIRD_TEST/TARGETS/$1 :=
endif
endif

# Discover previously failed tests if fail-first is enabled
ifneq ($$(bowerbird-test.config.fail-first),0)
ifndef BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1
BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1 := $$(call bowerbird::test::find-cached-test-results-failed,$$(bowerbird-test.constant.workdir-results)/$1,$$(bowerbird-test.constant.ext-fail))
endif
else
BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1 =
endif

# Split tests into primary (previously failed) and secondary (passing)
BOWERBIRD_TEST/TARGETS_PRIMARY/$1 := $$(filter $$(BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1),$$(BOWERBIRD_TEST/TARGETS/$1))
BOWERBIRD_TEST/TARGETS_SECONDARY/$1 := $$(filter-out $$(BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1),$$(BOWERBIRD_TEST/TARGETS/$1))

# Generate the include file (this is the key innovation)
# The file contains all test execution rules without using recursive Make for orchestration
$$(BOWERBIRD_GENERATED/$1): $$(BOWERBIRD_TEST/FILES/$1)
	@mkdir -p $$(dir $$@)
	@echo "# Auto-generated test execution rules for suite: $1" > $$@
	@echo "# Generated at: $$(shell date)" >> $$@
	@echo "" >> $$@
	$$(call __bowerbird::test::suite-generate-rules,$$@,$1)

# Include the generated file (Make will re-execute if it doesn't exist or is outdated)
-include $$(BOWERBIRD_GENERATED/$1)

# Main suite target depends on primary tests first, then secondary
.PHONY: $1
ifneq ($$(BOWERBIRD_TEST/TARGETS_PRIMARY/$1),)
$1: $$(foreach test,$$(BOWERBIRD_TEST/TARGETS_PRIMARY/$1),__test-wrapper/$1/$$(test)) __run-secondary-tests/$1
else
$1: $$(foreach test,$$(BOWERBIRD_TEST/TARGETS/$1),__test-wrapper/$1/$$(test))
endif
	@$$(eval BOWERBIRD_TEST/CACHE/TESTS_PASSED_CURR/$1 = $$(shell find \
			$$(bowerbird-test.constant.workdir-results)/$1 \
			-type f -name '*.$$(bowerbird-test.constant.ext-pass)' 2>/dev/null))
	$$(eval BOWERBIRD_TEST/CACHE/TESTS_FAILED_CURR/$1 = $$(shell find \
			$$(bowerbird-test.constant.workdir-results)/$1 \
			-type f -name '*.$$(bowerbird-test.constant.ext-fail)' 2>/dev/null))
	@test -z "$$(BOWERBIRD_TEST/CACHE/TESTS_PASSED_CURR/$1)" || cat $$(BOWERBIRD_TEST/CACHE/TESTS_PASSED_CURR/$1)
	@test -z "$$(BOWERBIRD_TEST/CACHE/TESTS_FAILED_CURR/$1)" || cat $$(BOWERBIRD_TEST/CACHE/TESTS_FAILED_CURR/$1)
	@test $$(words $$(BOWERBIRD_TEST/CACHE/TESTS_FAILED_CURR/$1)) -eq 0 || \
			(printf "\e[1;31mFailed: $1: $$(words $$(BOWERBIRD_TEST/CACHE/TESTS_FAILED_CURR/$1))/$$(words \
					$$(BOWERBIRD_TEST/TARGETS/$1)) failed\e[0m\n\n" && exit 1)
	@test $$(words $$(BOWERBIRD_TEST/CACHE/TESTS_PASSED_CURR/$1)) -eq $$(words $$(BOWERBIRD_TEST/TARGETS/$1)) || \
			(printf "\e[1;31mFailed: $1: Mismatch in the number of tests discovered: \
					$$(words $$(BOWERBIRD_TEST/CACHE/TESTS_PASSED_CURR/$1))/$$(words \
					$$(BOWERBIRD_TEST/TARGETS/$1)) passed\e[0m\n\n" && \
					echo "Test Target: $$(BOWERBIRD_TEST/TARGETS/$1)" && exit 1)
	@printf "\e[1;32mPassed: $1: $$(words $$(BOWERBIRD_TEST/CACHE/TESTS_PASSED_CURR/$1))/$$(words \
					$$(BOWERBIRD_TEST/TARGETS/$1)) passed\e[0m\n\n"

.PHONY: __run-secondary-tests/$1
__run-secondary-tests/$1: $$(foreach test,$$(BOWERBIRD_TEST/TARGETS_SECONDARY/$1),__test-wrapper/$1/$$(test))

endef


# Generate the test execution rules and write to file
# Includes fail-fast support and undefined variable detection
define __bowerbird::test::suite-generate-rules # output-file, suite-name
	@echo "# Test wrapper targets for suite: $2" >> $1
	@echo "" >> $1
	@for test in $(BOWERBIRD_TEST/TARGETS/$2); do \
		/bin/echo ".PHONY: __test-wrapper/$2/$$test" >> $1; \
		/bin/echo "__test-wrapper/$2/$$test:" >> $1; \
		/bin/echo "	@mkdir -p \$$(dir $(bowerbird-test.constant.workdir-logs)/$2/$$test.$(bowerbird-test.constant.ext-log))" >> $1; \
		/bin/echo "	@mkdir -p \$$(dir $(bowerbird-test.constant.workdir-results)/$2/$$test.$(bowerbird-test.constant.ext-pass))" >> $1; \
		/bin/echo "	@(\$$(MAKE) $$test --debug=v --warn-undefined-variables $(bowerbird-test.constant.process-tag) \\" >> $1; \
		/bin/echo "			>$(bowerbird-test.constant.workdir-logs)/$2/$$test.$(bowerbird-test.constant.ext-log) 2>&1 && \\" >> $1; \
		/bin/echo "			(! (grep -v \"grep.*$(bowerbird-test.constant.undefined-variable-warning)\" \\" >> $1; \
		/bin/echo "					$(bowerbird-test.constant.workdir-logs)/$2/$$test.$(bowerbird-test.constant.ext-log) | \\" >> $1; \
		/bin/echo "					grep --color=always \"^.*$(bowerbird-test.constant.undefined-variable-warning).*\$$\$$\" \\" >> $1; \
		/bin/echo "					>> $(bowerbird-test.constant.workdir-logs)/$2/$$test.$(bowerbird-test.constant.ext-log)) || exit 1) && \\" >> $1; \
		/bin/echo "			( \\" >> $1; \
		/bin/echo "				printf \"\e[1;32mPassed:\e[0m $$test\n\" && \\" >> $1; \
		/bin/echo "				printf \"\e[1;32mPassed:\e[0m $$test\n\" > $(bowerbird-test.constant.workdir-results)/$2/$$test.$(bowerbird-test.constant.ext-pass) \\" >> $1; \
		/bin/echo "			)) || \\" >> $1; \
		/bin/echo "		(\\" >> $1; \
		/bin/echo "			printf \"\e[1;31mFailed: $$test\e[0m\n\" && \\" >> $1; \
		/bin/echo "			printf \"\e[1;31mFailed: $$test\e[0m\n\" > $(bowerbird-test.constant.workdir-results)/$2/$$test.$(bowerbird-test.constant.ext-fail) && \\" >> $1; \
		/bin/echo "				echo && cat $(bowerbird-test.constant.workdir-logs)/$2/$$test.$(bowerbird-test.constant.ext-log) >&2 && \\" >> $1; \
		/bin/echo "				echo && printf \"\e[1;31mFailed: $$test\e[0m\n\" >&2 && \\" >> $1; \
		/bin/echo "					(test $(bowerbird-test.config.fail-fast) -eq 0 || (kill -TERM \$$\$$\$$(pgrep -f $(bowerbird-test.constant.process-tag)))) && \\" >> $1; \
		/bin/echo "					exit $(bowerbird-test.config.fail-exit-code) \\" >> $1; \
		/bin/echo "		)" >> $1; \
		/bin/echo "" >> $1; \
	done
endef


.PHONY: bowerbird-test/force
bowerbird-test/force:
	@:
