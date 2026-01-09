# Unit tests for __bowerbird::test::split-tests

_test_split_tests_output := $(call __bowerbird::test::split-tests,test-runner)


# Test: Returns non-empty syntax
test-suite-split-returns-syntax:
	$(call bowerbird::test::compare-strings,$(if $(_test_split_tests_output),pass,fail),pass)


# Test: Generated syntax exports primary targets variable
test-suite-split-exports-primary:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring export BOWERBIRD_TEST/TARGETS_PRIMARY/test-runner,$(_test_split_tests_output)),pass,fail)),pass)


# Test: Generated syntax exports secondary targets variable  
test-suite-split-exports-secondary:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring export BOWERBIRD_TEST/TARGETS_SECONDARY/test-runner,$(_test_split_tests_output)),pass,fail)),pass)


# Test: Primary uses filter to select failed tests
test-suite-split-primary-uses-filter:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring filter,$(_test_split_tests_output)),pass,fail)),pass)


# Test: Secondary uses filter-out to exclude failed tests
test-suite-split-secondary-uses-filter-out:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring filter-out,$(_test_split_tests_output)),pass,fail)),pass)


# Test: References cache of previously failed tests
test-suite-split-refs-cache:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring TESTS_PREV_FAILED,$(_test_split_tests_output)),pass,fail)),pass)


# Test: References all targets
test-suite-split-refs-targets:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring BOWERBIRD_TEST/TARGETS/test-runner,$(_test_split_tests_output)),pass,fail)),pass)


# Test: Wraps targets with run-test-target prefix
test-suite-split-wraps-targets:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring @bowerbird-test/run-test-target,$(_test_split_tests_output)),pass,fail)),pass)


# Test: Uses foreach to iterate targets
test-suite-split-uses-foreach:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring foreach,$(_test_split_tests_output)),pass,fail)),pass)
