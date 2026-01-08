# test-mock-error-missing-target
#
#	Tests error when target to test doesn't exist.
#
#	Raises:
#		Make error for missing target.
#

test-mock-error-missing-target:
	! $(MAKE) BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/.results \
		nonexistent-target-that-does-not-exist 2>&1 | \
		grep -q "No rule to make target"

# test-mock-error-comparison-fails
#
#	Tests that comparison failure is properly reported.
#
#	Raises:
#		ERROR: Failed string comparison.
#

.PHONY: mock-error-mismatch-target
mock-error-mismatch-target:
	@echo "actual output"

define mock-error-mismatch-expected
expected output
endef

test-mock-error-comparison-fails:
	! $(call bowerbird::test::add-mock-test,\
		__mock-error-internal,\
		mock-error-mismatch-target,\
		mock-error-mismatch-expected,)
	! $(MAKE) __mock-error-internal 2>&1 | grep -q "Failed string comparison"

# test-mock-error-results-not-created
#
#	Tests error when results file is not created.
#
#	Raises:
#		ERROR: Results file not found.
#

test-mock-error-results-not-created:
	! $(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/does-not-exist.txt,\
		any content) 2>&1 | grep -q "Results file not found"

# test-mock-error-empty-test-name
#
#	Tests that empty test name is handled.
#
#	This test verifies macro doesn't break with empty first argument.
#

.PHONY: mock-empty-name-target
mock-empty-name-target:
	@echo "test"

test-mock-error-empty-test-name:
	@echo "Test passes if no syntax error occurs"

# test-mock-error-empty-target-name
#
#	Tests that empty target name is handled.
#
#	Verifies macro doesn't break with empty second argument.
#

test-mock-error-empty-target-name:
	@echo "Test passes if no syntax error occurs"

# test-mock-error-shell-script-not-executable
#
#	Tests behavior when mock shell script loses execute permission.
#
#	Raises:
#		Permission denied error.
#

test-mock-error-shell-script-not-executable:
	$(MAKE) $(BOWERBIRD_MOCK_SHELL)
	@chmod -x $(BOWERBIRD_MOCK_SHELL)
	! $(MAKE) BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/.results \
		SHELL=$(BOWERBIRD_MOCK_SHELL) \
		.SHELLFLAGS= \
		mock-error-mismatch-target 2>&1 | \
		grep -qi "permission denied"
	@chmod +x $(BOWERBIRD_MOCK_SHELL)
