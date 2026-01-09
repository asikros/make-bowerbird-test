# Unit tests for __bowerbird::test::discover-files

_test_discover_files_output := $(call __bowerbird::test::discover-files,test-runner,test/mock-tests,test*.mk)


# Test: Returns non-empty syntax
test-suite-discover-files-returns-syntax:
	$(call bowerbird::test::compare-strings,$(if $(_test_discover_files_output),pass,fail),pass)


# Test: Generated syntax contains ifndef check
test-suite-discover-files-has-ifndef:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring ifndef BOWERBIRD_TEST/FILES/test-runner,$(_test_discover_files_output)),pass,fail)),pass)


# Test: Generated syntax contains export statement
test-suite-discover-files-has-export:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring export BOWERBIRD_TEST/FILES/test-runner,$(_test_discover_files_output)),pass,fail)),pass)


# Test: Generated syntax calls find-test-files macro
test-suite-discover-files-calls-find:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird::test::find-test-files,$(_test_discover_files_output)),pass,fail)),pass)


# Test: Generated syntax includes path argument
test-suite-discover-files-has-path:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring test/mock-tests,$(_test_discover_files_output)),pass,fail)),pass)


# Test: Generated syntax includes pattern argument
test-suite-discover-files-has-pattern:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring test*.mk,$(_test_discover_files_output)),pass,fail)),pass)


# Test: Generated syntax has warning for no files found
test-suite-discover-files-has-warning:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring No test files found,$(_test_discover_files_output)),pass,fail)),pass)
