# Unit tests for bowerbird::test::suite (dynamic include implementation)


# Test: Suite macro is defined
test-suite-macro-defined:
	test -n "$(strip $(value bowerbird::test::suite))"


# Test: Implementation macro is defined
test-suite-impl-macro-defined:
	test -n "$(strip $(value __bowerbird::test::suite-impl))"


# Test: Configuration defaults are set
test-suite-config-defaults-fail-exit-code:
	$(call bowerbird::test::compare-strings,$(bowerbird-test.config.fail-exit-code),0)


test-suite-config-defaults-fail-fast:
	$(call bowerbird::test::compare-strings,$(bowerbird-test.config.fail-fast),0)


test-suite-config-defaults-fail-first:
	$(call bowerbird::test::compare-strings,$(bowerbird-test.config.fail-first),0)


test-suite-config-defaults-file-patterns:
	$(call bowerbird::test::compare-strings,$(bowerbird-test.config.file-patterns),test*.mk)


test-suite-config-defaults-target-patterns:
	$(call bowerbird::test::compare-strings,$(bowerbird-test.config.target-patterns),test*)


# Test: Constants are defined correctly
test-suite-constant-ext-fail:
	$(call bowerbird::test::compare-strings,$(bowerbird-test.constant.ext-fail),fail)


test-suite-constant-ext-pass:
	$(call bowerbird::test::compare-strings,$(bowerbird-test.constant.ext-pass),pass)


test-suite-constant-ext-log:
	$(call bowerbird::test::compare-strings,$(bowerbird-test.constant.ext-log),log)


test-suite-constant-subdir-cache:
	$(call bowerbird::test::compare-strings,$(bowerbird-test.constant.subdir-cache),.bowerbird)


# Test: WORKDIR_TEST is required
test-suite-workdir-test-required:
	@output=$$($(MAKE) -f Makefile \
		WORKDIR_TEST= \
		test-suite-macro-defined 2>&1); \
	echo "$$output" | grep -q "ERROR: Undefined variable WORKDIR_TEST"
