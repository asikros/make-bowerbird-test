# Unit tests for __bowerbird::test::discover-failed-tests

_test_discover_failed_output := $(call __bowerbird::test::discover-failed-tests,test-runner)


# Test: Returns non-empty syntax
test-suite-discover-failed-returns-syntax:
	$(call bowerbird::test::compare-strings,$(if $(_test_discover_failed_output),pass,fail),pass)


# Test: Generated syntax contains ifneq for fail-first config
test-suite-discover-failed-has-ifneq:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring ifneq,$(_test_discover_failed_output)),pass,fail)),pass)


# Test: Generated syntax checks fail-first config
test-suite-discover-failed-checks-config:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird-test.config.fail-first,$(_test_discover_failed_output)),pass,fail)),pass)


# Test: Generated syntax has ifndef for cache var
test-suite-discover-failed-has-ifndef:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring ifndef BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/test-runner,$(_test_discover_failed_output)),pass,fail)),pass)


# Test: Generated syntax exports cache variable
test-suite-discover-failed-exports-var:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring export BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/test-runner,$(_test_discover_failed_output)),pass,fail)),pass)


# Test: Generated syntax calls find-failed-cached-test-results
test-suite-discover-failed-calls-find:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird::test::find-failed-cached-test-results,$(_test_discover_failed_output)),pass,fail)),pass)


# Test: Generated syntax has else clause
test-suite-discover-failed-has-else:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring else,$(_test_discover_failed_output)),pass,fail)),pass)


# Test: Else clause sets cache to empty
test-suite-discover-failed-else-empty:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/test-runner =,$(_test_discover_failed_output)),pass,fail)),pass)


# Test: Generated syntax references workdir-results
test-suite-discover-failed-has-workdir:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird-test.constant.workdir-results,$(_test_discover_failed_output)),pass,fail)),pass)


# Test: Generated syntax references ext-fail
test-suite-discover-failed-has-ext:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird-test.constant.ext-fail,$(_test_discover_failed_output)),pass,fail)),pass)
