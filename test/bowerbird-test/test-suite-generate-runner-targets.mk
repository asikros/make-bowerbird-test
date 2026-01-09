# Unit tests for __bowerbird::test::generate-runner-targets

_test_runner_targets_output := $(call __bowerbird::test::generate-runner-targets,test-runner)


# Test: Returns non-empty syntax
test-suite-runner-returns-syntax:
	$(call bowerbird::test::compare-strings,$(if $(_test_runner_targets_output),pass,fail),pass)


# Test: Generates list-discovered-tests target
test-suite-runner-has-list-target:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird-test/runner/list-discovered-tests/test-runner,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: list-discovered-tests is marked .PHONY
test-suite-runner-list-is-phony:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring .PHONY: bowerbird-test/runner/list-discovered-tests,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: Generates clean-results target
test-suite-runner-has-clean-target:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird-test/runner/clean-results/test-runner,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: clean-results is marked .PHONY
test-suite-runner-clean-is-phony:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring .PHONY: bowerbird-test/runner/clean-results,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: clean-results uses rm command
test-suite-runner-clean-uses-rm:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring rm,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: Generates run-primary-tests target
test-suite-runner-has-primary-target:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird-test/runner/run-primary-tests/test-runner,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: run-primary-tests is marked .PHONY
test-suite-runner-primary-is-phony:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring .PHONY: bowerbird-test/runner/run-primary-tests,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: run-primary-tests references PRIMARY list
test-suite-runner-primary-refs-list:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring TARGETS_PRIMARY,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: Generates run-secondary-tests target
test-suite-runner-has-secondary-target:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird-test/runner/run-secondary-tests/test-runner,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: run-secondary-tests is marked .PHONY
test-suite-runner-secondary-is-phony:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring .PHONY: bowerbird-test/runner/run-secondary-tests,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: run-secondary-tests references SECONDARY list
test-suite-runner-secondary-refs-list:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring TARGETS_SECONDARY,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: Generates report-results target
test-suite-runner-has-report-target:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird-test/runner/report-results/test-runner,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: report-results is marked .PHONY
test-suite-runner-report-is-phony:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring .PHONY: bowerbird-test/runner/report-results,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: report-results uses find command
test-suite-runner-report-uses-find:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring find,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: report-results checks for pass files
test-suite-runner-report-checks-pass:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring TESTS_PASSED_CURR,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: report-results checks for fail files
test-suite-runner-report-checks-fail:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring TESTS_FAILED_CURR,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: Generates main suite target
test-suite-runner-has-main-target:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring .PHONY: test-runner,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: Main target calls list-discovered-tests
test-suite-runner-main-calls-list:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring list-discovered-tests,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: Main target calls clean-results
test-suite-runner-main-calls-clean:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring clean-results,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: Main target calls report-results
test-suite-runner-main-calls-report:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring report-results,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: Has conditional for PRIMARY targets
test-suite-runner-has-primary-conditional:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring ifneq,$(_test_runner_targets_output)),pass,fail)),pass)


# Test: Has conditional for SECONDARY targets
test-suite-runner-has-secondary-conditional:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring ifneq,$(_test_runner_targets_output)),pass,fail)),pass)
