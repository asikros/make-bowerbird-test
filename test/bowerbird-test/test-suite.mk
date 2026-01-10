# Unit tests for bowerbird::test::suite (dynamic include implementation)


# Test: Suite macro is defined
test-suite-macro-defined:
	@test "$(flavor bowerbird::test::suite)" = "recursive" || (echo "ERROR: bowerbird::test::suite not defined" && exit 1)


# Test: Implementation macro is defined
test-suite-impl-macro-defined:
	@test "$(flavor bowerbird::test::__suite-impl)" = "recursive" || (echo "ERROR: bowerbird::test::__suite-impl not defined" && exit 1)


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


# Test: WORKDIR_TEST is defined (checking it's set in bowerbird-suite.mk)
test-suite-workdir-test-required:
	@test -n "$(WORKDIR_TEST)" || (echo "ERROR: WORKDIR_TEST not set" && exit 1)


# Error message tests - Make-generated errors require recursive make

test-suite-error-missing-target:
	@output=$$(printf '%s\n' \
		'include src/bowerbird-test/bowerbird-suite.mk' \
		'WORKDIR_TEST=$(WORKDIR_TEST)' \
		'$$(call bowerbird::test::suite,,test/)' \
		'test:' | \
		$(MAKE) --no-print-directory -f - test 2>&1 || true); \
		echo "$$output" | grep -q "ERROR: missing target"


test-suite-error-missing-path:
	@output=$$(printf '%s\n' \
		'include src/bowerbird-test/bowerbird-suite.mk' \
		'WORKDIR_TEST=$(WORKDIR_TEST)' \
		'$$(call bowerbird::test::suite,test-target,)' \
		'test:' | \
		$(MAKE) --no-print-directory -f - test 2>&1 || true); \
		echo "$$output" | grep -q "ERROR: missing path"


test-suite-warning-no-files-found:
	@mkdir -p $(WORKDIR_TEST)/$@/empty-dir
	@output=$$(printf '%s\n' \
		'include src/bowerbird-test/bowerbird-suite.mk' \
		'WORKDIR_TEST=$(WORKDIR_TEST)/$@' \
		'$$(call bowerbird::test::suite,test-empty,$(WORKDIR_TEST)/$@/empty-dir)' \
		'test: test-empty' | \
		$(MAKE) --no-print-directory -f - test 2>&1 || true); \
		echo "$$output" | grep -q "WARNING: No test files found"
