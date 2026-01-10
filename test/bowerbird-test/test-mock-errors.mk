test-mock-error-missing-target:
	@$(MAKE) BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/.results \
		nonexistent-target-that-does-not-exist 2>&1 | \
		grep -q "No rule to make target"


.PHONY: mock-error-mismatch-target
mock-error-mismatch-target:
	@echo "actual output"

define mock-error-mismatch-expected
echo "expected output"
endef

$(call bowerbird::test::add-mock-test,\
	__test-mock-error-internal,\
	mock-error-mismatch-target,\
	mock-error-mismatch-expected,)

test-mock-error-comparison-fails:
	@$(MAKE) __test-mock-error-internal 2>&1 | grep -q "Content mismatch"


.PHONY: mock-empty-name-target
mock-empty-name-target:
	@echo "test"

test-mock-error-empty-test-name:
	@echo "Test passes if no syntax error occurs"


test-mock-error-empty-target-name:
	@echo "Test passes if no syntax error occurs"
