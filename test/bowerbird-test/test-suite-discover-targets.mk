# Unit tests for __bowerbird::test::discover-targets

_test_discover_targets_output := $(call __bowerbird::test::discover-targets,test-runner)


# Test: Returns non-empty syntax
test-suite-discover-targets-returns-syntax:
	$(call bowerbird::test::compare-strings,$(if $(_test_discover_targets_output),pass,fail),pass)


# Test: Generated syntax contains ifneq check for files
test-suite-discover-targets-has-ifneq:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring ifneq,$(_test_discover_targets_output)),pass,fail)),pass)


# Test: Generated syntax contains include statement
test-suite-discover-targets-has-include:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring include,$(_test_discover_targets_output)),pass,fail)),pass)


# Test: Generated syntax checks MAKEFILE_LIST
test-suite-discover-targets-checks-makefile-list:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring MAKEFILE_LIST,$(_test_discover_targets_output)),pass,fail)),pass)


# Test: Generated syntax contains ifndef for targets
test-suite-discover-targets-has-ifndef:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring ifndef BOWERBIRD_TEST/TARGETS/test-runner,$(_test_discover_targets_output)),pass,fail)),pass)


# Test: Generated syntax exports targets variable
test-suite-discover-targets-exports-var:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring export BOWERBIRD_TEST/TARGETS/test-runner,$(_test_discover_targets_output)),pass,fail)),pass)


# Test: Generated syntax calls find-test-targets
test-suite-discover-targets-calls-find:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird::test::find-test-targets,$(_test_discover_targets_output)),pass,fail)),pass)


# Test: Generated syntax has else clause for empty files
test-suite-discover-targets-has-else:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring else,$(_test_discover_targets_output)),pass,fail)),pass)


# Test: Else clause sets targets to empty
test-suite-discover-targets-else-empty:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring BOWERBIRD_TEST/TARGETS/test-runner =,$(_test_discover_targets_output)),pass,fail)),pass)
