# Test Suite Generation
#
# Provides macros for creating test suite targets that discover and execute tests.
# Uses constructed include files to avoid recursive Make orchestration overhead.
#
# Features:
#   - Fail-fast: Kills all running tests on first failure
#   - Fail-first: Runs previously failed tests first
#   - Undefined variable detection per test
#   - Colored output and detailed reporting
#   - Test isolation via recursive Make per test

WORKDIR_TEST ?= $(error ERROR: Undefined variable WORKDIR_TEST)

# Include guard prevents "overriding commands for target" warnings when this
# file is included multiple times.
ifndef __BOWERBIRD_TEST_FLAGS_DEFINED
__BOWERBIRD_TEST_FLAGS_DEFINED := 1

# --bowerbird-fail-fast
#
#	Optional flag to kill all tests on first failure.
#
#	When enabled, all parallel test processes are terminated immediately
#	when the first test failure is detected.
#
#	Example:
#		make test -- --bowerbird-fail-fast
#		make check -- --bowerbird-fail-fast
#
__BOWERBIRD_FAIL_FAST_FLAG = --bowerbird-fail-fast
.PHONY: $(__BOWERBIRD_FAIL_FAST_FLAG)
$(__BOWERBIRD_FAIL_FAST_FLAG):
	@:

# --bowerbird-fail-first
#
#	Optional flag to run previously failed tests first.
#
#	When enabled, tests that failed in the previous run are executed before
#	tests that passed, allowing faster iteration on failures.
#
#	Example:
#		make test -- --bowerbird-fail-first
#		make check -- --bowerbird-fail-first
#
__BOWERBIRD_FAIL_FIRST_FLAG = --bowerbird-fail-first
.PHONY: $(__BOWERBIRD_FAIL_FIRST_FLAG)
$(__BOWERBIRD_FAIL_FIRST_FLAG):
	@:

# --bowerbird-suppress-warnings
#
#	Optional flag to suppress warning messages during test discovery.
#
#	When enabled, warnings about missing test files or empty test directories
#	are suppressed.
#
#	Example:
#		make test -- --bowerbird-suppress-warnings
#		make check -- --bowerbird-suppress-warnings
#
__BOWERBIRD_SUPPRESS_WARNINGS_FLAG = --bowerbird-suppress-warnings
.PHONY: $(__BOWERBIRD_SUPPRESS_WARNINGS_FLAG)
$(__BOWERBIRD_SUPPRESS_WARNINGS_FLAG):
	@:

endif

# Set option value for --bowerbird-fail-fast
ifneq ($(filter $(__BOWERBIRD_FAIL_FAST_FLAG),$(MAKECMDGOALS)),)
    bowerbird-test.option.fail-fast = 1
else
    bowerbird-test.option.fail-fast = 0
endif

# Set option value for --bowerbird-fail-first
ifneq ($(filter $(__BOWERBIRD_FAIL_FIRST_FLAG),$(MAKECMDGOALS)),)
    bowerbird-test.option.fail-first = 1
else
    bowerbird-test.option.fail-first = 0
endif

# Set option value for --bowerbird-suppress-warnings
ifneq ($(filter $(__BOWERBIRD_SUPPRESS_WARNINGS_FLAG),$(MAKECMDGOALS)),)
    bowerbird-test.option.suppress-warnings = 1
else
    bowerbird-test.option.suppress-warnings = 0
endif

# Configuration (can be overridden before including this file)
bowerbird-test.config.file-patterns ?= test*.mk
bowerbird-test.config.target-patterns ?= test*

# Constants
bowerbird-test.constant.ext-fail = fail
bowerbird-test.constant.ext-log = log
bowerbird-test.constant.ext-pass = pass
bowerbird-test.constant.fail-exit-code = 1
bowerbird-test.constant.generated-dir = $(WORKDIR_TEST)/.generated
bowerbird-test.constant.process-tag = __BOWERBIRD_TEST_PROCESS_TAG__=$(shell echo $$PPID)
bowerbird-test.constant.subdir-cache = .bowerbird
bowerbird-test.constant.undefined-variable-warning = warning: undefined variable
bowerbird-test.constant.workdir-logs = $(WORKDIR_TEST)/$(bowerbird-test.constant.subdir-cache)
bowerbird-test.constant.workdir-results = $(WORKDIR_TEST)/$(bowerbird-test.constant.subdir-cache)


# bowerbird::test::suite, target, paths, file-patterns, target-patterns
#
#   Creates a target for running all the test targets discovered in the specified test
#	file paths using dynamic include files to reduce orchestration overhead.
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
#       paths: Space-separated list of starting directory paths for the search.
#       file-patterns: (Optional) Space-separated list of file patterns (default: test*.mk)
#       target-patterns: (Optional) Space-separated list of target patterns (default: test*)
#
#   Options (can be set via command line flags):
#       bowerbird-test.option.fail-fast: Kill all tests on first failure (default: 0, set via --bowerbird-fail-fast)
#       bowerbird-test.option.fail-first: Run failed tests first (default: 0, set via --bowerbird-fail-first)
#       bowerbird-test.option.suppress-warnings: Suppress warning messages (default: 0, set via --bowerbird-suppress-warnings)
#
#   Constants:
#       bowerbird-test.constant.fail-exit-code: Exit code for failed tests (value: 1)
#
#	Error:
#		Throws an error if target empty.
#		Throws an error if paths empty.
#
#   Performance:
#   - ~2% faster than previous implementation (eliminates 5 orchestration calls)
#   - Generates ~256KB .mk file per suite (cached between runs)
#
#   Example:
#       $(call bowerbird::test::suite,test-target,test-dir)
#       $(call bowerbird::test::suite,test-all,test-dir1 test-dir2)
#       $(call bowerbird::test::suite,test-all,test-dir,test*.mk check*.mk,test* check*)
# 		make test-target
#
define bowerbird::test::suite # target, paths, file-patterns, target-patterns
$(eval $(call bowerbird::test::__suite-impl,$1,$2,$(if $3,$3,$(bowerbird-test.config.file-patterns)),$(if $4,$4,$(bowerbird-test.config.target-patterns))))
endef


# Generate the include file path for this suite
define bowerbird::test::__suite-generated-file # suite-name
$(bowerbird-test.constant.generated-dir)/$1.mk
endef


# Main implementation - generates the include file and loads it
define bowerbird::test::__suite-impl # target, paths, file-patterns, target-patterns
# Validation
$$(if $1,,$$(error ERROR: missing target in '$$$$(call bowerbird::test::suite,<target>,<paths>)'))
$$(if $2,,$$(error ERROR: missing paths in '$$$$(call bowerbird::test::suite,$1,<paths>)'))

# Check if suite is being redefined with different configuration (to catch accidental redefinition)
# Configuration fingerprint includes: paths, file-patterns, target-patterns
BOWERBIRD_TEST/CONFIG_NEW/$1 := $$(sort $2)|$$(sort $3)|$$(sort $4)
ifdef BOWERBIRD_TEST/CONFIG/$1
ifneq ($$(BOWERBIRD_TEST/CONFIG/$1),$$(BOWERBIRD_TEST/CONFIG_NEW/$1))
$$(error ERROR: test suite '$1' is already defined with different configuration (paths or patterns). Cannot redefine. Each suite target must have a unique configuration.)
endif
else
BOWERBIRD_TEST/CONFIG/$1 := $$(BOWERBIRD_TEST/CONFIG_NEW/$1)
BOWERBIRD_TEST/PATHS/$1 := $$(sort $2)
BOWERBIRD_TEST/FILE_PATTERNS/$1 := $$(sort $3)
BOWERBIRD_TEST/TARGET_PATTERNS/$1 := $$(sort $4)
endif

# Define the generated file path
BOWERBIRD_GENERATED/$1 := $$(call bowerbird::test::__suite-generated-file,$1)

# Discover test files using specified patterns (supports multiple paths and patterns)
# Note: Variable may already be defined during recursive Make re-parsing, but since we validated
# that paths match (above), rediscovering would yield the same files. We rediscover anyway to
# avoid confusion and ensure consistency.
export BOWERBIRD_TEST/FILES/$1 := $$(call bowerbird::test::find-test-files,$2,$3)
$$(if $$(BOWERBIRD_TEST/FILES/$1),,$$(if $$(filter 1,$$(bowerbird-test.option.suppress-warnings)),,$$(warning WARNING: No test files found in '$2' matching '$3')))


# Include test files to get targets (but only if not already included)
# First check: Skip if no test files were found
ifneq (,$$(BOWERBIRD_TEST/FILES/$1))
# Second check: Skip if test files are already in MAKEFILE_LIST (prevents duplicate includes)
ifeq ($$(filter $$(MAKEFILE_LIST),$$(BOWERBIRD_TEST/FILES/$1)),)
include $$(BOWERBIRD_TEST/FILES/$1)
endif
endif

# Discover test targets using specified patterns (supports multiple patterns)
ifneq (,$$(BOWERBIRD_TEST/FILES/$1))
export BOWERBIRD_TEST/TARGETS/$1 := $$(call bowerbird::test::find-test-targets,$$(BOWERBIRD_TEST/FILES/$1),$4)
else
export BOWERBIRD_TEST/TARGETS/$1 :=
endif

# Discover previously failed tests if fail-first is enabled
ifneq ($$(bowerbird-test.option.fail-first),0)
BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1 := $$(call bowerbird::test::find-cached-test-results-failed,$$(bowerbird-test.constant.workdir-results)/$1)
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
	$$(call bowerbird::test::__suite-generate-rules,$$@,$1)

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
					$$(BOWERBIRD_TEST/TARGETS/$1)) failed\e[0m\n\n" && exit $$(bowerbird-test.constant.fail-exit-code))
	@test $$(words $$(BOWERBIRD_TEST/CACHE/TESTS_PASSED_CURR/$1)) -eq $$(words $$(BOWERBIRD_TEST/TARGETS/$1)) || \
			(printf "\e[1;31mFailed: $1: Mismatch in the number of tests discovered: \
					$$(words $$(BOWERBIRD_TEST/CACHE/TESTS_PASSED_CURR/$1))/$$(words \
					$$(BOWERBIRD_TEST/TARGETS/$1)) passed\e[0m\n\n" && \
					echo "Test Target: $$(BOWERBIRD_TEST/TARGETS/$1)" && exit $$(bowerbird-test.constant.fail-exit-code))
	@printf "\e[1;32mPassed: $1: $$(words $$(BOWERBIRD_TEST/CACHE/TESTS_PASSED_CURR/$1))/$$(words \
					$$(BOWERBIRD_TEST/TARGETS/$1)) passed\e[0m\n\n"

.PHONY: __run-secondary-tests/$1
__run-secondary-tests/$1: $$(foreach test,$$(BOWERBIRD_TEST/TARGETS_SECONDARY/$1),__test-wrapper/$1/$$(test))

endef


# Generate the test execution rules and write to file
# Uses a single pattern rule instead of individual explicit targets for performance
# Includes fail-fast support and undefined variable detection
define bowerbird::test::__suite-generate-rules # output-file, suite-name
	@printf '%s\n' \
		'# Suite-specific variables for: $2' \
		'BOWERBIRD_TEST/SUITE/$2/workdir-logs := $(bowerbird-test.constant.workdir-logs)/$2' \
		'BOWERBIRD_TEST/SUITE/$2/workdir-results := $(bowerbird-test.constant.workdir-results)/$2' \
		'BOWERBIRD_TEST/SUITE/$2/process-tag := $(bowerbird-test.constant.process-tag)' \
		'BOWERBIRD_TEST/SUITE/$2/fail-fast := $(bowerbird-test.option.fail-fast)' \
		'BOWERBIRD_TEST/SUITE/$2/fail-exit-code := $(bowerbird-test.constant.fail-exit-code)' \
		'BOWERBIRD_TEST/SUITE/$2/undefined-var-warning := $(bowerbird-test.constant.undefined-variable-warning)' \
		'BOWERBIRD_TEST/SUITE/$2/ext-log := $(bowerbird-test.constant.ext-log)' \
		'BOWERBIRD_TEST/SUITE/$2/ext-pass := $(bowerbird-test.constant.ext-pass)' \
		'BOWERBIRD_TEST/SUITE/$2/ext-fail := $(bowerbird-test.constant.ext-fail)' \
		'' \
		'# Pattern rule handles all test wrapper targets for suite: $2' \
		'# Automatic variable $$* expands to the test name' \
		'__test-wrapper/$2/%:' \
		'	@mkdir -p $$(dir $$(BOWERBIRD_TEST/SUITE/$2/workdir-logs)/$$*.$$(BOWERBIRD_TEST/SUITE/$2/ext-log))' \
	'	@($$(MAKE) $$* --debug=v --warn-undefined-variables $$(BOWERBIRD_TEST/SUITE/$2/process-tag) \' \
	'			>$$(BOWERBIRD_TEST/SUITE/$2/workdir-logs)/$$*.$$(BOWERBIRD_TEST/SUITE/$2/ext-log) 2>&1 && \' \
	'			(! (sed "s/\x1b\[[0-9;]*[a-zA-Z]//g" $$(BOWERBIRD_TEST/SUITE/$2/workdir-logs)/$$*.$$(BOWERBIRD_TEST/SUITE/$2/ext-log) | \' \
	'					grep -v "grep.*$$(BOWERBIRD_TEST/SUITE/$2/undefined-var-warning)" | \' \
	'					grep -v "make/deps.mk.*$$(BOWERBIRD_TEST/SUITE/$2/undefined-var-warning)" | \' \
	'					grep --color=always "^.*$$(BOWERBIRD_TEST/SUITE/$2/undefined-var-warning).*$$$$" \' \
	'					>> $$(BOWERBIRD_TEST/SUITE/$2/workdir-logs)/$$*.$$(BOWERBIRD_TEST/SUITE/$2/ext-log)) || exit $$(BOWERBIRD_TEST/SUITE/$2/fail-exit-code)) && \' \
		'			( \' \
		'				printf "\e[1;32mPassed:\e[0m $$*\n" && \' \
		'				printf "\e[1;32mPassed:\e[0m $$*\n" > $$(BOWERBIRD_TEST/SUITE/$2/workdir-results)/$$*.$$(BOWERBIRD_TEST/SUITE/$2/ext-pass) \' \
		'			)) || \' \
		'		(\' \
		'			printf "\e[1;31mFailed: $$*\e[0m\n" && \' \
		'			printf "\e[1;31mFailed: $$*\e[0m\n" > $$(BOWERBIRD_TEST/SUITE/$2/workdir-results)/$$*.$$(BOWERBIRD_TEST/SUITE/$2/ext-fail) && \' \
		'				echo && cat $$(BOWERBIRD_TEST/SUITE/$2/workdir-logs)/$$*.$$(BOWERBIRD_TEST/SUITE/$2/ext-log) >&2 && \' \
		'				echo && printf "\e[1;31mFailed: $$*\e[0m\n" >&2 && \' \
		'					(test $$(BOWERBIRD_TEST/SUITE/$2/fail-fast) -eq 0 || (kill -TERM $$$$(pgrep -f $$(BOWERBIRD_TEST/SUITE/$2/process-tag)))) && \' \
		'					exit $$(BOWERBIRD_TEST/SUITE/$2/fail-exit-code) \' \
		'		)' \
		>> $1
endef


.PHONY: bowerbird-test/force
bowerbird-test/force:
	@:
