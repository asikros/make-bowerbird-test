$(call bowerbird::test::generate-runner,mock-test-run-test-target-runner,mock-path)


test-run-test-targets-failing-test-non-zero-exit-status:
	! $(MAKE) @bowerbird-test/run-test-target/mock-test/$@/failing-test/mock-test-run-test-target-runner \
			BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE=1


test-run-test-targets-failing-test-zero-exit-status:
	$(MAKE) @bowerbird-test/run-test-target/mock-test/$@/failing-test/mock-test-run-test-target-runner \
			BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE=0


test-run-test-targets-failing-test-generate-log-file:
	$(call scrub_file,$(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/mock-test-run-test-target-runner/mock-test/$@/failing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_LOG))
	$(MAKE) @bowerbird-test/run-test-target/mock-test/$@/failing-test/mock-test-run-test-target-runner \
			BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE=0
	test -f $(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/mock-test-run-test-target-runner/mock-test/$@/failing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_LOG)


test-run-test-targets-failing-test-generate-failed-response-file:
	$(call scrub_file,$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/failing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL))
	$(MAKE) @bowerbird-test/run-test-target/mock-test/$@/failing-test/mock-test-run-test-target-runner \
			BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE=0
	test -f $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/failing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL)


test-run-test-targets-failing-test-do-not-generate-passing-response-file:
	$(call scrub_file,$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/failing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_PASS))
	$(MAKE) @bowerbird-test/run-test-target/mock-test/$@/failing-test/mock-test-run-test-target-runner \
			BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE=0
	test ! -f $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/failing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_PASS)


test-run-test-targets-failing-test-response-file-contents:
	$(call scrub_file,$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/failing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL))
	$(MAKE) @bowerbird-test/run-test-target/mock-test/$@/failing-test/mock-test-run-test-target-runner \
			BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE=0 2>/dev/null
	test -f $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/failing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL)
	$(call bowerbird::test::compare-strings,\
			$$(cat $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/failing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL)),\
			$(shell printf "\e[1;31mFailed: mock-test/test-run-test-targets-failing-test-response-file-contents/failing-test\e[0m"))


test-run-test-targets-passing-test-generate-log-file:
	$(call scrub_file,$(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/mock-test-run-test-target-runner/mock-test/$@/passing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_LOG))
	$(MAKE) @bowerbird-test/run-test-target/mock-test/$@/passing-test/mock-test-run-test-target-runner
	test -f $(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/mock-test-run-test-target-runner/mock-test/$@/passing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_LOG)


test-run-test-targets-passing-test-generate-passing-response-file:
	$(call scrub_file,$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/passing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_PASS))
	$(MAKE) @bowerbird-test/run-test-target/mock-test/$@/passing-test/mock-test-run-test-target-runner \
			BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE=0
	test -f $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/passing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_PASS)


test-run-test-targets-passing-test-do-not-generate-failing-response-file:
	$(call scrub_file,$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/passing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL))
	$(MAKE) @bowerbird-test/run-test-target/mock-test/$@/passing-test/mock-test-run-test-target-runner \
			BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE=0
	test ! -f $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/passing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL)


test-run-test-targets-passing-test-response-file-contents:
	$(call scrub_file,$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/passing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_PASS))
	$(MAKE) @bowerbird-test/run-test-target/mock-test/$@/passing-test/mock-test-run-test-target-runner \
			BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE=0 2>/dev/null
	test -f $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/passing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_PASS)
	$(call bowerbird::test::compare-strings,\
			$$(cat $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/passing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_PASS)),\
			$(shell printf "\e[1;32mPassed:\e[0m mock-test/test-run-test-targets-passing-test-response-file-contents/passing-test"))


test-run-test-targets-undefined-variable-ensure-test-variable-is-undefined:
	! $(MAKE) mock-test/force BOWERBIRD_TEST_VARIABLE=true


test-run-test-targets-undefined-variable-non-zero-exit-status:
	! $(MAKE) @bowerbird-test/run-test-target/mock-test/$@/undefined-variable-test/mock-test-run-test-target-runner \
			BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE=1 2>/dev/null


test-run-test-targets-undefined-variable-zero-exit-status:
	$(MAKE) @bowerbird-test/run-test-target/mock-test/$@/undefined-variable-test/mock-test-run-test-target-runner \
			BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE=0 2>/dev/null


test-run-test-targets-undefined-variable-generate-log-file:
	$(call scrub_file,$(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/mock-test-run-test-target-runner/mock-test/$@/undefined-variable-test.$(BOWERBIRD_TEST/CONSTANT/EXT_LOG))
	$(MAKE) @bowerbird-test/run-test-target/mock-test/$@/undefined-variable-test/mock-test-run-test-target-runner \
			BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE=0 2>/dev/null
	test -f $(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/mock-test-run-test-target-runner/mock-test/$@/undefined-variable-test.$(BOWERBIRD_TEST/CONSTANT/EXT_LOG)


test-run-test-targets-undefined-variable-test-generate-failed-response-file:
	$(call scrub_file,$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/undefined-variable-test.$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL))
	$(MAKE) @bowerbird-test/run-test-target/mock-test/$@/undefined-variable-test/mock-test-run-test-target-runner \
			BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE=0 2>/dev/null
	test -f $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/undefined-variable-test.$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL)


test-run-test-targets-undefined-variable-test-do-not-generate-passing-response-file:
	$(call scrub_file,$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/undefined-variable-test.$(BOWERBIRD_TEST/CONSTANT/EXT_PASS))
	$(MAKE) @bowerbird-test/run-test-target/mock-test/$@/undefined-variable-test/mock-test-run-test-target-runner \
			BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE=0 2>/dev/null
	test ! -f $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/undefined-variable-test.$(BOWERBIRD_TEST/CONSTANT/EXT_PASS)


test-run-test-targets-undefined-variable-test-response-file-contents:
	$(call scrub_file,$(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/undefined-variable-test.$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL))
	$(MAKE) @bowerbird-test/run-test-target/mock-test/$@/undefined-variable-test/mock-test-run-test-target-runner \
			BOWERBIRD_TEST/CONFIG/FAIL_EXIT_CODE=0 2>/dev/null
	test -f $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/undefined-variable-test.$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL)
	$(call bowerbird::test::compare-strings,\
			$$(cat $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-test-run-test-target-runner/mock-test/$@/undefined-variable-test.$(BOWERBIRD_TEST/CONSTANT/EXT_FAIL)),\
			$(shell printf "\e[1;31mFailed: mock-test/test-run-test-targets-undefined-variable-test-response-file-contents/undefined-variable-test\e[0m"))


test-run-test-targets-hierarchical-name-generate-log-file:
	$(call scrub_file,$(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/mock-test-run-test-target-runner/mock-test/$@/alpha/beta/passing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_LOG))
	$(MAKE) @bowerbird-test/run-test-target/mock-test/$@/alpha/beta/passing-test/mock-test-run-test-target-runner
	test -f $(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/mock-test-run-test-target-runner/mock-test/$@/alpha/beta/passing-test.$(BOWERBIRD_TEST/CONSTANT/EXT_LOG)


mock-test/%/passing-test: mock-test/force
	exit 0


mock-test/%/failing-test: mock-test/force
	exit 1


mock-test/%/undefined-variable-test: mock-test/force
	echo $(BOWERBIRD_TEST_VARIABLE)


ifdef BOWERBIRD_TEST_VARIABLE
    $(error ERROR: Unable to run test with: BOWERBIRD_TEST_VARIABLE is not an undefined variable.)
endif


.PHONY: mock-test/force
.mock-test/force:
	@:


define scrub_file
test -n "$1" && test ! -f $1 || rm -f $1; test ! -f $1
endef
