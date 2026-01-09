# Unit tests for __bowerbird::test::reset-config

_test_reset_config_output := $(call __bowerbird::test::reset-config)


# Test: Returns non-empty syntax
test-suite-reset-returns-syntax:
	$(call bowerbird::test::compare-strings,$(if $(_test_reset_config_output),pass,fail),pass)


# Test: Resets file-pattern-user to default
test-suite-reset-resets-file-pattern:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird-test.config.file-pattern-user,$(_test_reset_config_output)),pass,fail)),pass)


# Test: Resets target-pattern-user to default
test-suite-reset-resets-target-pattern:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird-test.config.target-pattern-user,$(_test_reset_config_output)),pass,fail)),pass)


# Test: Uses := assignment for immediate expansion
test-suite-reset-uses-immediate-assignment:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring :=,$(_test_reset_config_output)),pass,fail)),pass)


# Test: References file-pattern-default
test-suite-reset-refs-file-default:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird-test.config.file-pattern-default,$(_test_reset_config_output)),pass,fail)),pass)


# Test: References target-pattern-default
test-suite-reset-refs-target-default:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird-test.config.target-pattern-default,$(_test_reset_config_output)),pass,fail)),pass)
