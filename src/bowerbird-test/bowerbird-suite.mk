WORKDIR_TEST ?= $(error ERROR: Undefined variable WORKDIR_TEST)

bowerbird-test.config.fail-exit-code = 0
bowerbird-test.config.fail-fast = 0
bowerbird-test.config.fail-first = 0
bowerbird-test.config.file-pattern-default = test*.mk
bowerbird-test.config.file-pattern-user = $(bowerbird-test.config.file-pattern-default)
bowerbird-test.config.suppress-warnings = 0
bowerbird-test.config.target-pattern-default = test*
bowerbird-test.config.target-pattern-user = $(bowerbird-test.config.target-pattern-default)

bowerbird-test.constant.ext-fail = fail
bowerbird-test.constant.ext-log = log
bowerbird-test.constant.ext-pass = pass
bowerbird-test.constant.process-tag = __BOWERBIRD_TEST_PROCESS_TAG__=$(bowerbird-test.system.makepid)
bowerbird-test.constant.subdir-cache = .bowerbird
bowerbird-test.constant.undefined-variable-warning = warning: undefined variable
bowerbird-test.constant.workdir-logs = $(bowerbird-test.constant.workdir-root)/$(bowerbird-test.constant.subdir-cache)
bowerbird-test.constant.workdir-results = $(bowerbird-test.constant.workdir-root)/$(bowerbird-test.constant.subdir-cache)
bowerbird-test.constant.workdir-root = $(WORKDIR_TEST)

bowerbird-test.system.makepid := $(shell echo $$PPID)


# bowerbird::test::pattern-test-files,<patterns>
#
#   Updates the filename pattern for test discovery used only by the next invocation of
#   bowerbird::test::generate-runner. The call to bowerbird::test::generate-runner will
#	revert the filename pattern back to the default value such that subsequent calls to
#	bowerbird::test::generate-runner will use the default filename pattern.
#
#   Args:
#       pattern: Wildcard filename pattern.
#
#   Example:
#       $(call bowerbird::test::pattern-test-files,test*.mk)
#       $(call bowerbird::test::pattern-test-files,*test.*)
#
define bowerbird::test::pattern-test-files
$(eval bowerbird-test.config.file-pattern-user := $1)
endef


# bowerbird::test::pattern-test-targets,<patterns>
#
#   Updates the target pattern for test discovery used only by the next invocation of
#   bowerbird::test::generate-runner. The call to bowerbird::test::generate-runner will
#	revert the target pattern back to the default value such that subsequent calls to
#	bowerbird::test::generate-runner will use the default target patten.
#
#   Args:
#       pattern: Wildcard target pattern.
#
#   Example:
#       $(call bowerbird::test::pattern-test-targets,test*)
#       $(call bowerbird::test::pattern-test-targets,*_check)
#
define bowerbird::test::pattern-test-targets
$(eval bowerbird-test.config.target-pattern-user := $1)
endef


# bowerbird::test::suite,<target>,<path>
#
#   Creates a target for running all the test targets discovered in the specified test
#	file path.
#
#   Args:
#       target: Name of the test suite target to create.
#       path: Starting directory name for the search.
#
#   Configuration:
#       pattern-test-files: Wildcard filename pattern used during test discovery.
#			Refer to bowerbird::test::pattern-test-files for more information about
#			changing this value. Defaults to 'test*.mk'.
#       pattern-test-targets: Wildcard target pattern used during test discovery.
#			Refer to bowerbird::test::pattern-test-targets for more information about
#			changing this value. Defaults to 'test*'.
#
#	Error:
#		Throws an error if target empty.
#		Throws an error if path empty.
#
#   Example:
#       $(call bowerbird::test::suite,test-target,test-dir)
# 		make test-target
#
define bowerbird::test::suite # target, path
$(eval $(call __bowerbird::test::suite-impl,$1,$2))
endef


# __bowerbird::test::validate-args,<target>,<path>
#
#   Validates that target and path arguments are non-empty.
#   Returns: Makefile syntax for validation checks
#
define __bowerbird::test::validate-args # target, path
$$(if $1,,$$(error ERROR: missing target in '$$$$(call bowerbird::test::suite,<target>,<path>)))
$$(if $2,,$$(error ERROR: missing path in '$$$$(call bowerbird::test::suite,$1,)))
endef


# __bowerbird::test::discover-files,<suite-name>,<path>,<pattern>
#
#   Discovers test files and sets BOWERBIRD_TEST/FILES/<suite-name>.
#   Returns: Makefile syntax for file discovery
#
define __bowerbird::test::discover-files # suite-name, path, pattern
ifndef BOWERBIRD_TEST/FILES/$1
export BOWERBIRD_TEST/FILES/$1 := $$(call bowerbird::test::find-test-files,$2,$3)
$$(if $$(BOWERBIRD_TEST/FILES/$1),,$$(if $$(filter 0,$$(bowerbird-test.config.suppress-warnings)),$$(warning WARNING: No test files found in '$2' matching '$3')))
endif
endef


# __bowerbird::test::discover-targets,<suite-name>
#
#   Includes test files and discovers test targets.
#   Returns: Makefile syntax for target discovery
#
define __bowerbird::test::discover-targets # suite-name
ifneq (,$$(BOWERBIRD_TEST/FILES/$1))
ifeq ($$(filter $$(MAKEFILE_LIST),$$(BOWERBIRD_TEST/FILES/$1)),)
include $$(BOWERBIRD_TEST/FILES/$1)
endif
ifndef BOWERBIRD_TEST/TARGETS/$1
export BOWERBIRD_TEST/TARGETS/$1 := $$(call bowerbird::test::find-test-targets,$$(BOWERBIRD_TEST/FILES/$1))
endif
else
BOWERBIRD_TEST/TARGETS/$1 =
endif
endef


# __bowerbird::test::discover-failed-tests,<suite-name>
#
#   Finds previously failed tests if fail-first is enabled.
#   Returns: Makefile syntax for failed test discovery
#
define __bowerbird::test::discover-failed-tests # suite-name
ifneq ($$(bowerbird-test.config.fail-first),0)
ifndef BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1
export BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1 := $(call bowerbird::test::find-failed-cached-test-results,$$(bowerbird-test.constant.workdir-results)/$1,$$(bowerbird-test.constant.ext-fail))
endif
else
BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1 =
endif
endef


# __bowerbird::test::split-tests,<suite-name>
#
#   Splits tests into primary (failed) and secondary (passing) lists.
#   Returns: Makefile syntax for test list generation
#
define __bowerbird::test::split-tests # suite-name
export BOWERBIRD_TEST/TARGETS_PRIMARY/$1 := $$(foreach target,$$(filter $$(BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1),$$(BOWERBIRD_TEST/TARGETS/$1)),@bowerbird-test/run-test-target/$$(target)/$1)
export BOWERBIRD_TEST/TARGETS_SECONDARY/$1 := $$(foreach target,$$(filter-out $$(BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1),$$(BOWERBIRD_TEST/TARGETS/$1)),@bowerbird-test/run-test-target/$$(target)/$1)
endef


# __bowerbird::test::generate-runner-targets,<suite-name>
#
#   Generates all runner helper targets (list, clean, run, report, main).
#   Returns: Makefile syntax for runner targets
#
define __bowerbird::test::generate-runner-targets # suite-name
.PHONY: bowerbird-test/runner/list-discovered-tests/$1
bowerbird-test/runner/list-discovered-tests/$1:
	@echo "Discovered tests"; $$(foreach t,$$(sort $$(BOWERBIRD_TEST/TARGETS/$1)),echo "    $$t";)

.PHONY: bowerbird-test/runner/clean-results/$1
bowerbird-test/runner/clean-results/$1:
	@test -n $$(bowerbird-test.constant.workdir-results)/$1
	@mkdir -p $$(bowerbird-test.constant.workdir-results)/$1
	@test -d $$(bowerbird-test.constant.workdir-results)/$1
	@rm -f $$(bowerbird-test.constant.workdir-results)/$1/*

.PHONY: bowerbird-test/runner/run-primary-tests/$1
bowerbird-test/runner/run-primary-tests/$1: $$(BOWERBIRD_TEST/TARGETS_PRIMARY/$1)

.PHONY: bowerbird-test/runner/run-secondary-tests/$1
bowerbird-test/runner/run-secondary-tests/$1: $$(BOWERBIRD_TEST/TARGETS_SECONDARY/$1)

.PHONY: bowerbird-test/runner/report-results/$1
bowerbird-test/runner/report-results/$1:
	@$$(eval BOWERBIRD_TEST/CACHE/TESTS_PASSED_CURR/$1 = $$(shell find \
			$$(bowerbird-test.constant.workdir-results)/$1 \
			-type f -name '*.$$(bowerbird-test.constant.ext-pass)'))
	$$(eval BOWERBIRD_TEST/CACHE/TESTS_FAILED_CURR/$1 = $$(shell find \
			$$(bowerbird-test.constant.workdir-results)/$1 \
			-type f -name '*.$$(bowerbird-test.constant.ext-fail)'))
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

.PHONY: $1
$1:
	@test "$(bowerbird-test.constant.ext-fail)" != "$(bowerbird-test.constant.ext-pass)"
	@$(MAKE) bowerbird-test/runner/list-discovered-tests/$1
	@$(MAKE) bowerbird-test/runner/clean-results/$1
ifneq ($$(BOWERBIRD_TEST/TARGETS_PRIMARY/$1),)
	@$(MAKE) bowerbird-test/runner/run-primary-tests/$1
endif
ifneq ($$(BOWERBIRD_TEST/TARGETS_SECONDARY/$1),)
	@$(MAKE) bowerbird-test/runner/run-secondary-tests/$1
endif
	@$(MAKE) bowerbird-test/runner/report-results/$1
endef


# __bowerbird::test::generate-pattern-rule,<suite-name>
#
#   Generates the pattern rule for running individual tests.
#   Returns: Makefile syntax for test execution pattern rule
#
define __bowerbird::test::generate-pattern-rule # suite-name
@bowerbird-test/run-test-target/%/$1: bowerbird-test/force
	@mkdir -p $$(dir $$(bowerbird-test.constant.workdir-logs)/$1/$$*)
	@mkdir -p $$(dir $$(bowerbird-test.constant.workdir-results)/$1/$$*)
	@($(MAKE) $$* --debug=v --warn-undefined-variables $$(bowerbird-test.constant.process-tag) \
			>$$(bowerbird-test.constant.workdir-logs)/$1/$$*.$$(bowerbird-test.constant.ext-log) 2>&1 && \
			(! (grep -v "grep.*$$(bowerbird-test.constant.undefined-variable-warning)" \
					$$(bowerbird-test.constant.workdir-logs)/$1/$$*.$$(bowerbird-test.constant.ext-log) | \
					grep --color=always "^.*$$(bowerbird-test.constant.undefined-variable-warning).*$$$$" \
					>> $$(bowerbird-test.constant.workdir-logs)/$1/$$*.$$(bowerbird-test.constant.ext-log)) || exit 1) && \
			( \
				printf "\e[1;32mPassed:\e[0m $$*\n" && \
				printf "\e[1;32mPassed:\e[0m $$*\n" > $$(bowerbird-test.constant.workdir-results)/$1/$$*.$$(bowerbird-test.constant.ext-pass) \
			)) || \
		(\
			printf "\e[1;31mFailed: $$*\e[0m\n" && \
			printf "\e[1;31mFailed: $$*\e[0m\n" > $$(bowerbird-test.constant.workdir-results)/$1/$$*.$$(bowerbird-test.constant.ext-fail) && \
				echo && cat $$(bowerbird-test.constant.workdir-logs)/$1/$$*.$$(bowerbird-test.constant.ext-log) >&2 && \
				echo && printf "\e[1;31mFailed: $$*\e[0m\n" >&2 && \
					(test $$(bowerbird-test.config.fail-fast) -eq 0 || (kill -TERM $$$$(pgrep -f $$(bowerbird-test.constant.process-tag)))) && \
					exit $$(bowerbird-test.config.fail-exit-code) \
		)
endef


# __bowerbird::test::reset-config
#
#   Resets pattern configuration to defaults.
#   Returns: Makefile syntax for config reset
#
define __bowerbird::test::reset-config # (no args)
bowerbird-test.config.file-pattern-user := $$(bowerbird-test.config.file-pattern-default)
bowerbird-test.config.target-pattern-user := $$(bowerbird-test.config.target-pattern-default)
endef


# Master implementation that orchestrates the test suite by calling all sub-macros
define __bowerbird::test::suite-impl # target, path
$(call __bowerbird::test::validate-args,$1,$2)
$(call __bowerbird::test::discover-files,$1,$2,$(bowerbird-test.config.file-pattern-user))
$(call __bowerbird::test::discover-targets,$1)
$(call __bowerbird::test::discover-failed-tests,$1)
$(call __bowerbird::test::split-tests,$1)
$(call __bowerbird::test::generate-runner-targets,$1)
$(call __bowerbird::test::generate-pattern-rule,$1)
$(call __bowerbird::test::reset-config)
endef


.PHONY: bowerbird-test/force
bowerbird-test/force:
	@:
