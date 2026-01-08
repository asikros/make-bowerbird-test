# Test file with multi-line add-mock-test calls

.PHONY: mock-multiline-target
mock-multiline-target:
	@echo "multiline"

define mock-multiline-expected
echo multiline
endef

$(call bowerbird::test::add-mock-test,\
	test-multiline-four-continuations,\
	mock-multiline-target,\
	mock-multiline-expected,\
	)

# Target with very long name
test-this-is-a-very-long-target-name-that-tests-boundary-conditions:
	@:
