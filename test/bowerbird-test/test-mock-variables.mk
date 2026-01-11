# Unit tests for mock shell variable expansion and special characters

.PHONY: mock-test-variables
mock-test-variables: MOCK_VAR = testvalue
mock-test-variables: MOCK_DIR = /tmp/mockdir
mock-test-variables:
	@echo "Variable: $(MOCK_VAR)"
	@mkdir -p $(MOCK_DIR)

define mock-variables-expected
echo "Variable: testvalue"
mkdir -p /tmp/mockdir
endef

$(call bowerbird::test::add-mock-test,\
	test-mock-with-variables,\
	mock-test-variables,\
	mock-variables-expected,)


.PHONY: mock-test-special-chars
mock-test-special-chars:
	@echo "double quotes"
	@echo "with spaces and tabs"

define mock-special-chars-expected
echo "double quotes"
echo "with spaces and tabs"
endef

$(call bowerbird::test::add-mock-test,\
	test-mock-special-chars-quotes,\
	mock-test-special-chars,\
	mock-special-chars-expected,)


.PHONY: mock-test-dollars
mock-test-dollars: DOLLAR_VAR = value
mock-test-dollars:
	@echo "Variable: $(DOLLAR_VAR)"
	@echo "Literal: $$HOME"

define mock-dollars-expected
echo "Variable: value"
echo "Literal: $HOME"
endef

$(call bowerbird::test::add-mock-test,\
	test-mock-dollar-signs,\
	mock-test-dollars,\
	mock-dollars-expected,)


.PHONY: mock-test-dir-creation
mock-test-dir-creation:
	@echo "Testing directory creation"

define mock-dir-creation-expected
echo "Testing directory creation"
endef

$(call bowerbird::test::add-mock-test,\
	test-mock-results-directory-creation,\
	mock-test-dir-creation,\
	mock-dir-creation-expected,)
