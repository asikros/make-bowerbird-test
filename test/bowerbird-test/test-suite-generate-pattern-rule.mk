# Unit tests for __bowerbird::test::generate-pattern-rule

_test_pattern_rule_output := $(call __bowerbird::test::generate-pattern-rule,test-runner)


# Test: Returns non-empty syntax
test-suite-pattern-returns-syntax:
	$(call bowerbird::test::compare-strings,$(if $(_test_pattern_rule_output),pass,fail),pass)


# Test: Generates pattern rule with correct prefix
test-suite-pattern-has-prefix:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring @bowerbird-test/run-test-target/%/test-runner,$(_test_pattern_rule_output)),pass,fail)),pass)


# Test: Pattern rule uses pattern target syntax
test-suite-pattern-has-pattern-target:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring @bowerbird-test/run-test-target/%,$(_test_pattern_rule_output)),pass,fail)),pass)


# Test: Pattern rule creates log directory
test-suite-pattern-creates-log-dir:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring mkdir -p,$(_test_pattern_rule_output)),pass,fail)),pass)


# Test: Pattern rule references workdir-logs
test-suite-pattern-refs-logs:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring workdir-logs,$(_test_pattern_rule_output)),pass,fail)),pass)


# Test: Pattern rule references workdir-results
test-suite-pattern-refs-results:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring workdir-results,$(_test_pattern_rule_output)),pass,fail)),pass)


# Test: Pattern rule generates complex recipe (multi-statement recipe)
test-suite-pattern-has-recipe:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(word 10,$(_test_pattern_rule_output)),pass,fail)),pass)


# Test: Pattern rule uses warn-undefined-variables
test-suite-pattern-uses-warn-undefined:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring warn-undefined-variables,$(_test_pattern_rule_output)),pass,fail)),pass)


# Test: Pattern rule creates .pass file on success
test-suite-pattern-creates-pass:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring ext-pass,$(_test_pattern_rule_output)),pass,fail)),pass)


# Test: Pattern rule creates .fail file on failure
test-suite-pattern-creates-fail:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring ext-fail,$(_test_pattern_rule_output)),pass,fail)),pass)


# Test: Pattern rule handles both success and failure cases
test-suite-pattern-handles-both-cases:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring Passed:,$(_test_pattern_rule_output)),pass,fail)),pass)


# Test: Pattern rule outputs test name (uses automatic variable for stem)
test-suite-pattern-outputs-test-name:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring printf,$(_test_pattern_rule_output)),pass,fail)),pass)


# Test: Pattern rule uses process tag
test-suite-pattern-uses-process-tag:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird-test.constant.process-tag,$(_test_pattern_rule_output)),pass,fail)),pass)


# Test: Pattern rule checks for undefined variable warning
test-suite-pattern-checks-warning:
	$(call bowerbird::test::compare-strings,$(strip \
		$(if $(findstring bowerbird-test.constant.undefined-variable-warning,$(_test_pattern_rule_output)),pass,fail)),pass)
