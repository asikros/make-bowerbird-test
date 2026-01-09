.PHONY: mock-test-simple-target
mock-test-simple-target:
	@echo "Hello, World!"
	@mkdir -p /tmp/test
	@echo "Done"

define mock-basic-expected
echo "Hello, World!"
mkdir -p /tmp/test
echo "Done"
endef

$(call bowerbird::test::add-mock-test,\
test-mock-basic,\
mock-test-simple-target,\
mock-basic-expected,)


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


.PHONY: mock-test-multi-commands
mock-test-multi-commands:
	@echo "Step 1"
	@echo "Step 2"
	@echo "Step 3"
	@echo "Step 4"
	@echo "Step 5"

define mock-multi-commands-expected
echo "Step 1"
echo "Step 2"
echo "Step 3"
echo "Step 4"
echo "Step 5"
endef

$(call bowerbird::test::add-mock-test,\
test-mock-multiple-commands,\
mock-test-multi-commands,\
mock-multi-commands-expected,)


.PHONY: mock-multiline-basic
mock-multiline-basic:
	@echo "Line 1"
	@echo "Line 2"

define mock-multiline-basic-expected
echo "Line 1"
echo "Line 2"
endef

$(call bowerbird::test::add-mock-test,\
test-mock-multiline-basic,\
mock-multiline-basic,\
mock-multiline-basic-expected,)


.PHONY: mock-multiline-indented
mock-multiline-indented:
	@echo "Indented"

define mock-multiline-indented-expected
echo "Indented"
endef

$(call bowerbird::test::add-mock-test,\
test-mock-multiline-indented,\
mock-multiline-indented,\
mock-multiline-indented-expected,)


.PHONY: mock-multiline-complex
mock-multiline-complex:
	@mkdir -p /tmp/test1
	@mkdir -p /tmp/test2
	@mkdir -p /tmp/test3
	@echo "Done with directories"

define mock-multiline-complex-expected
mkdir -p /tmp/test1
mkdir -p /tmp/test2
mkdir -p /tmp/test3
echo "Done with directories"
endef

$(call bowerbird::test::add-mock-test,\
test-mock-multiline-complex,\
mock-multiline-complex,\
mock-multiline-complex-expected,)


.PHONY: mock-multiline-with-vars-inner
mock-multiline-with-vars-inner:
	@echo "Variable mode enabled"

define mock-multiline-with-vars-expected
echo "Variable mode enabled"
endef

ifdef __TEST_MULTILINE_VARS
.PHONY: mock-multiline-with-vars-target
mock-multiline-with-vars-target:
	@echo "Variable mode enabled"
endif

$(call bowerbird::test::add-mock-test,\
test-mock-multiline-with-vars,\
mock-multiline-with-vars-target,\
mock-multiline-with-vars-expected,\
__TEST_MULTILINE_VARS=1)


test-mock-shell-script-exists:
	@test -f $(BOWERBIRD_MOCK_SHELL)
	@test -x $(BOWERBIRD_MOCK_SHELL)


.PHONY: mock-test-empty
mock-test-empty:

define mock-empty-expected
endef

$(call bowerbird::test::add-mock-test,\
test-mock-empty-output,\
mock-test-empty,\
mock-empty-expected,)


.PHONY: mock-test-no-at
mock-test-no-at:
	echo "No at prefix"

define mock-no-at-expected
echo "No at prefix"
endef

$(call bowerbird::test::add-mock-test,\
test-mock-without-at-prefix,\
mock-test-no-at,\
mock-no-at-expected,)


.PHONY: mock-test-mixed
mock-test-mixed:
	@echo "With at"
	echo "Without at"
	@echo "With at again"

define mock-mixed-expected
echo "With at"
echo "Without at"
echo "With at again"
endef

$(call bowerbird::test::add-mock-test,\
test-mock-mixed-at-prefix,\
mock-test-mixed,\
mock-mixed-expected,)


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
echo "Literal: $$HOME"
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


.PHONY: mock-test-appending
mock-test-appending:
	@echo "First"
	@echo "Second"
	@echo "Third"

define mock-appending-expected
echo "First"
echo "Second"
echo "Third"
endef

$(call bowerbird::test::add-mock-test,\
test-mock-results-appending,\
mock-test-appending,\
mock-appending-expected,)


.PHONY: mock-test-long-command
mock-test-long-command:
	@echo "This is a very long command line with many arguments that should still be captured correctly by the mock shell framework"

define mock-long-command-expected
echo "This is a very long command line with many arguments that should still be captured correctly by the mock shell framework"
endef

$(call bowerbird::test::add-mock-test,\
test-mock-long-command-line,\
mock-test-long-command,\
mock-long-command-expected,)


.PHONY: mock-test-auto-phony
mock-test-auto-phony:
	@echo "Auto phony test"

define mock-auto-phony-expected
echo "Auto phony test"
endef

$(call bowerbird::test::add-mock-test,\
test-mock-automatic-phony,\
mock-test-auto-phony,\
mock-auto-phony-expected,)
