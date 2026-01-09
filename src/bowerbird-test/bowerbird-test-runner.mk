WORKDIR_TEST ?= $(error ERROR: Undefined variable WORKDIR_TEST)

BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE = 0
BOWERBIRD_TEST/CONFIG/FAIL_FAST = 0
BOWERBIRD_TEST/CONFIG/FAIL_FIRST = 0
BOWERBIRD_TEST/CONFIG/FILE_PATTERN_DEFAULT = test*.mk
BOWERBIRD_TEST/CONFIG/FILE_PATTERN_USER = $(BOWERBIRD_TEST/CONFIG/FILE_PATTERN_DEFAULT)
BOWERBIRD_TEST/CONFIG/TARGET_PATTERN_DEFAULT = test*
BOWERBIRD_TEST/CONFIG/TARGET_PATTERN_USER = $(BOWERBIRD_TEST/CONFIG/TARGET_PATTERN_DEFAULT)

BOWERBIRD_TEST/CONSTANT/PROCESS_TAG = __BOWERBIRD_TEST_PROCESS_TAG__=$(BOWERBIRD_TEST/SYSTEM/MAKEPID)
BOWERBIRD_TEST/CONSTANT/EXT_FAIL = fail
BOWERBIRD_TEST/CONSTANT/EXT_LOG = log
BOWERBIRD_TEST/CONSTANT/EXT_PASS = pass
BOWERBIRD_TEST/CONSTANT/SUBDIR_CACHE = .bowerbird
BOWERBIRD_TEST/CONSTANT/UNDEFINED_VARIABLE_WARNING = warning: undefined variable
BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS = $(BOWERBIRD_TEST/CONSTANT/WORKDIR_ROOT)/$(BOWERBIRD_TEST/CONSTANT/SUBDIR_CACHE)
BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS = $(BOWERBIRD_TEST/CONSTANT/WORKDIR_ROOT)/$(BOWERBIRD_TEST/CONSTANT/SUBDIR_CACHE)
BOWERBIRD_TEST/CONSTANT/WORKDIR_ROOT = $(WORKDIR_TEST)

BOWERBIRD_TEST/SYSTEM/MAKEPID := $(shell echo $$PPID)


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
$(eval BOWERBIRD_TEST/CONFIG/FILE_PATTERN_USER := $1)
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
$(eval BOWERBIRD_TEST/CONFIG/TARGET_PATTERN_USER := $1)
endef


# bowerbird::test::generate-runner,<target>,<path>
#
#   Creates a target for running all the test targets discovered in the specified test
#	file path.
#
#   Args:
#       target: Name of the test-runner target to create.
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
#       $(call bowerbird::test::generate-runner,test-target,test-dir)
# 		make test-target
#
define bowerbird::test::generate-runner # target, path
$(eval $(call __bowerbird::test::generate-runner-impl,$1,$2))
endef


# Private implementation (called via $(eval) by bowerbird::test::generate-runner)
define __bowerbird::test::generate-runner-impl
    $$(if $1,,$$(error ERROR: missing target in '$$$$(call bowerbird::test::generate-runner,<target>,<path>)))
    $$(if $2,,$$(error ERROR: missing path in '$$$$(call bowerbird::test::generate-runner,$1,)))
    ifndef BOWERBIRD_TEST/FILES/$1
        export BOWERBIRD_TEST/FILES/$1 := $$(call bowerbird::test::find-test-files,$2,$$(BOWERBIRD_TEST/CONFIG/FILE_PATTERN_USER))
        $$(if $$(BOWERBIRD_TEST/FILES/$1),,$$(warning WARNING: No test files found in '$2' matching '$$(BOWERBIRD_TEST/CONFIG/FILE_PATTERN_USER)'))
    endif
    ifneq (,$$(BOWERBIRD_TEST/FILES/$1))
        ifndef BOWERBIRD_TEST/TARGETS/$1
            export BOWERBIRD_TEST/TARGETS/$1 := $$(call bowerbird::test::find-test-targets,$$(BOWERBIRD_TEST/FILES/$1),$$(BOWERBIRD_TEST/CONFIG/TARGET_PATTERN_USER))
        endif
        ifeq ($$(filter $$(MAKEFILE_LIST),$$(BOWERBIRD_TEST/FILES/$1)),)
            include $$(BOWERBIRD_TEST/FILES/$1)
        endif
    else
        BOWERBIRD_TEST/TARGETS/$1 =
    endif
    ifneq ($$(BOWERBIRD_TEST/CONFIG/FAIL_FIRST),0)
        ifndef BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1
            export BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1 := $(call bowerbird::test::find-failed-cached-test-results,$$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/$1,$$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL))
        endif
    else
        BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1 =
    endif
    export BOWERBIRD_TEST/TARGETS_PRIMARY/$1 := $$(foreach target,$$(filter $$(BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1),$$(BOWERBIRD_TEST/TARGETS/$1)),@bowerbird-test/run-test-target/$$(target)/$1)
    export BOWERBIRD_TEST/TARGETS_SECONDARY/$1 := $$(foreach target,$$(filter-out $$(BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/$1),$$(BOWERBIRD_TEST/TARGETS/$1)),@bowerbird-test/run-test-target/$$(target)/$1)

    .PHONY: bowerbird-test/runner/list-discovered-tests/$1
    bowerbird-test/runner/list-discovered-tests/$1:
		@echo "Discovered tests"; $$(foreach t,$$(sort $$(BOWERBIRD_TEST/TARGETS/$1)),echo "    $$t";)

    .PHONY: bowerbird-test/runner/clean-results/$1
    bowerbird-test/runner/clean-results/$1:
		@test -n $$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/$1
		@mkdir -p $$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/$1
		@test -d $$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/$1
		@rm -f $$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/$1/*

    .PHONY: bowerbird-test/runner/run-primary-tests/$1
    bowerbird-test/runner/run-primary-tests/$1: $$(BOWERBIRD_TEST/TARGETS_PRIMARY/$1)

    .PHONY: bowerbird-test/runner/run-secondary-tests/$1
    bowerbird-test/runner/run-secondary-tests/$1: $$(BOWERBIRD_TEST/TARGETS_SECONDARY/$1)

    .PHONY: bowerbird-test/runner/report-results/$1
    bowerbird-test/runner/report-results/$1:
		@$$(eval BOWERBIRD_TEST/CACHE/TESTS_PASSED_CURR/$1 = $$(shell find \
				$$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/$1 \
				-type f -name '*.$$(BOWERBIRD_TEST/CONSTANT/EXT_PASS)'))
		$$(eval BOWERBIRD_TEST/CACHE/TESTS_FAILED_CURR/$1 = $$(shell find \
				$$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/$1 \
				-type f -name '*.$$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL)'))
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
    $1: bowerbird-test/ensure-mock-shell-executable
		@test "$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL)" != "$(BOWERBIRD_TEST/CONSTANT/EXT_PASS)"
		@$(MAKE) bowerbird-test/runner/list-discovered-tests/$1
		@$(MAKE) bowerbird-test/runner/clean-results/$1
ifneq ($$(BOWERBIRD_TEST/TARGETS_PRIMARY/$1),)
		@$(MAKE) bowerbird-test/runner/run-primary-tests/$1
endif
ifneq ($$(BOWERBIRD_TEST/TARGETS_SECONDARY/$1),)
		@$(MAKE) bowerbird-test/runner/run-secondary-tests/$1
endif
		@$(MAKE) bowerbird-test/runner/report-results/$1


    @bowerbird-test/run-test-target/%/$1: bowerbird-test/force
		@mkdir -p $$(dir $$(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/$1/$$*)
		@mkdir -p $$(dir $$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/$1/$$*)
		@($(MAKE) $$* --debug=v --warn-undefined-variables $$(BOWERBIRD_TEST/CONSTANT/PROCESS_TAG) \
				>$$(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/$1/$$*.$$(BOWERBIRD_TEST/CONSTANT/EXT_LOG) 2>&1 && \
				(! (grep -v "grep.*$$(BOWERBIRD_TEST/CONSTANT/UNDEFINED_VARIABLE_WARNING)" \
						$$(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/$1/$$*.$$(BOWERBIRD_TEST/CONSTANT/EXT_LOG) | \
						grep --color=always "^.*$$(BOWERBIRD_TEST/CONSTANT/UNDEFINED_VARIABLE_WARNING).*$$$$" \
						>> $$(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/$1/$$*.$$(BOWERBIRD_TEST/CONSTANT/EXT_LOG)) || exit 1) && \
				( \
					printf "\e[1;32mPassed:\e[0m $$*\n" && \
					printf "\e[1;32mPassed:\e[0m $$*\n" > $$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/$1/$$*.$$(BOWERBIRD_TEST/CONSTANT/EXT_PASS) \
				)) || \
			(\
				printf "\e[1;31mFailed: $$*\e[0m\n" && \
				printf "\e[1;31mFailed: $$*\e[0m\n" > $$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/$1/$$*.$$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL) && \
					echo && cat $$(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/$1/$$*.$$(BOWERBIRD_TEST/CONSTANT/EXT_LOG) >&2 && \
					echo && printf "\e[1;31mFailed: $$*\e[0m\n" >&2 && \
						(test $$(BOWERBIRD_TEST/CONFIG/FAIL_FAST) -eq 0 || (kill -TERM $$$$(pgrep -f $$(BOWERBIRD_TEST/CONSTANT/PROCESS_TAG)))) && \
						exit $$(BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE) \
			)

    BOWERBIRD_TEST/CONFIG/FILE_PATTERN_USER := $$(BOWERBIRD_TEST/CONFIG/FILE_PATTERN_DEFAULT)
    BOWERBIRD_TEST/CONFIG/TARGET_PATTERN_USER := $$(BOWERBIRD_TEST/CONFIG/TARGET_PATTERN_DEFAULT)
endef


.PHONY: bowerbird-test/force
bowerbird-test/force:
	@:

.PHONY: bowerbird-test/ensure-mock-shell-executable
bowerbird-test/ensure-mock-shell-executable: $(BOWERBIRD_MOCK_SHELL)

$(BOWERBIRD_MOCK_SHELL): $(BOWERBIRD_MOCK_SHELL_REAL)
	@printf '%s\n' \
		'#!/bin/sh' \
		'# Wrapper to invoke real mock shell through /bin/sh to bypass macOS quarantine' \
		'exec /bin/sh $(BOWERBIRD_MOCK_SHELL_REAL) "$$@"' \
		> $@
	@chmod +x $@

$(BOWERBIRD_MOCK_SHELL_REAL):
	@printf '%s\n' \
		'#!/bin/sh' \
		'# Extract command (always last argument after SHELLFLAGS)' \
		'eval "COMMAND=\"\$${$$#}\""' \
		'echo "$$COMMAND" >> "$${BOWERBIRD_MOCK_RESULTS:?BOWERBIRD_MOCK_RESULTS must be set}"' \
		> $@
	@chmod +x $@
