# Unit tests for __bowerbird::test::validate-args

_test_validate_output := $(call __bowerbird::test::validate-args,my-target,my/path)


# Test: Returns non-empty syntax
test-suite-validate-returns-syntax:
	$(call bowerbird::test::compare-strings,$(if $(_test_validate_output),pass,fail),pass)


# Test: Generated syntax validates arguments (contains conditional logic)
test-suite-validate-has-conditional:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(word 2,$(_test_validate_output)),pass,fail)),pass)


# Test: Generated syntax contains error directive for missing args
test-suite-validate-has-error-keyword:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring ERROR:,$(_test_validate_output)),pass,fail)),pass)


# Test: Generated syntax contains error for missing target
test-suite-validate-error-target:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring missing target,$(_test_validate_output)),pass,fail)),pass)


# Test: Generated syntax contains error for missing path
test-suite-validate-error-path:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring missing path,$(_test_validate_output)),pass,fail)),pass)


# Test: Error message references public API
test-suite-validate-references-public-api:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird::test::suite,$(_test_validate_output)),pass,fail)),pass)
