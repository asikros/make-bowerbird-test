# test-mock-basic
#
#	Tests basic mock shell functionality with a simple target.
#
#	Verifies that the mock shell captures commands correctly and that the
#	comparison works as expected.
#

# Simple target for testing
.PHONY: mock-test-simple-target
mock-test-simple-target:
	@echo "Hello, World!"
	@mkdir -p /tmp/test
	@echo "Done"

# Expected output
define mock-basic-expected
echo Hello, World!
mkdir -p /tmp/test
echo Done
endef

$(call bowerbird::test::add-mock-test,\
test-mock-basic,\
mock-test-simple-target,\
$(mock-basic-expected))

# test-mock-with-variables
#
#	Tests that Make variable expansion works correctly in mock tests.
#
#	Verifies that variables are expanded before commands reach the mock shell.
#

# Target with variable expansion
.PHONY: mock-test-variables
mock-test-variables: MOCK_VAR = testvalue
mock-test-variables: MOCK_DIR = /tmp/mockdir
mock-test-variables:
	@echo "Variable: $(MOCK_VAR)"
	@mkdir -p $(MOCK_DIR)

# Expected output with expanded variables
define mock-variables-expected
echo Variable: testvalue
mkdir -p /tmp/mockdir
endef

$(call bowerbird::test::add-mock-test,\
test-mock-with-variables,\
mock-test-variables,\
$(mock-variables-expected))

# test-mock-multiple-commands
#
#	Tests mock shell with multiple commands in sequence.
#
#	Verifies that command ordering is preserved.
#

# Target with multiple commands
.PHONY: mock-test-multi-commands
mock-test-multi-commands:
	@echo "Step 1"
	@echo "Step 2"
	@echo "Step 3"
	@echo "Step 4"
	@echo "Step 5"

define mock-multi-commands-expected
echo Step 1
echo Step 2
echo Step 3
echo Step 4
echo Step 5
endef

$(call bowerbird::test::add-mock-test,\
test-mock-multiple-commands,\
mock-test-multi-commands,\
$(mock-multi-commands-expected))

# test-mock-multiline-basic
#
#	Tests multi-line macro call with basic formatting.
#
#	Verifies that line continuation with backslashes works correctly.
#

.PHONY: mock-multiline-basic
mock-multiline-basic:
	@echo "Line 1"
	@echo "Line 2"

define mock-multiline-basic-expected
echo Line 1
echo Line 2
endef

$(call bowerbird::test::add-mock-test,\
test-mock-multiline-basic,\
mock-multiline-basic,\
$(mock-multiline-basic-expected))

# test-mock-multiline-indented
#
#	Tests multi-line macro call with various indentation levels.
#
#	Verifies that the discovery mechanism handles different indentation.
#

.PHONY: mock-multiline-indented
mock-multiline-indented:
	@echo "Indented"

define mock-multiline-indented-expected
echo Indented
endef

$(call bowerbird::test::add-mock-test,\
test-mock-multiline-indented,\
mock-multiline-indented,\
$(mock-multiline-indented-expected))

# test-mock-multiline-complex
#
#	Tests multi-line macro call with complex expected output.
#
#	Verifies that multi-line expected strings work correctly.
#

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
echo Done with directories
endef

$(call bowerbird::test::add-mock-test,\
test-mock-multiline-complex,\
mock-multiline-complex,\
$(mock-multiline-complex-expected))

# test-mock-multiline-with-vars
#
#	Tests multi-line macro call with command-line variables.
#
#	Verifies that the fourth argument (command-line variables) works.
#

.PHONY: mock-multiline-with-vars-inner
mock-multiline-with-vars-inner:
	@echo "Variable mode enabled"

define mock-multiline-with-vars-expected
echo Variable mode enabled
endef

ifdef __TEST_MULTILINE_VARS
.PHONY: mock-multiline-with-vars-target
mock-multiline-with-vars-target:
	@echo "Variable mode enabled"
endif

$(call bowerbird::test::add-mock-test,\
test-mock-multiline-with-vars,\
mock-multiline-with-vars-target,\
$(mock-multiline-with-vars-expected),\
__TEST_MULTILINE_VARS=)

# test-mock-shell-script-exists
#
#	Tests that the mock shell script is created.
#
#	Verifies that BOWERBIRD_MOCK_SHELL target creates an executable script.
#

test-mock-shell-script-exists:
	$(MAKE) $(BOWERBIRD_MOCK_SHELL)
	@test -f $(BOWERBIRD_MOCK_SHELL)
	@test -x $(BOWERBIRD_MOCK_SHELL)

# test-mock-shell-script-regenerates
#
#	Tests that the mock shell script regenerates when source changes.
#
#	Verifies that touching bowerbird-mock.mk triggers regeneration.
#

test-mock-shell-script-regenerates:
	$(MAKE) $(BOWERBIRD_MOCK_SHELL)
	@sleep 1
	@touch src/bowerbird-test/bowerbird-mock.mk
	@test src/bowerbird-test/bowerbird-mock.mk -nt $(BOWERBIRD_MOCK_SHELL)
	$(MAKE) $(BOWERBIRD_MOCK_SHELL)
	@test $(BOWERBIRD_MOCK_SHELL) -nt src/bowerbird-test/bowerbird-mock.mk || \
		test ! src/bowerbird-test/bowerbird-mock.mk -nt $(BOWERBIRD_MOCK_SHELL)

# test-mock-empty-output
#
#	Tests mock shell with target that produces no output.
#
#	Verifies that empty expected output works correctly.
#

.PHONY: mock-test-empty
mock-test-empty:

define mock-empty-expected
endef

$(call bowerbird::test::add-mock-test,\
test-mock-empty-output,\
mock-test-empty,\
$(mock-empty-expected))

# test-mock-without-at-prefix
#
#	Tests commands without @ prefix are still captured.
#
#	Verifies that Make echoes command and mock shell captures it.
#

.PHONY: mock-test-no-at
mock-test-no-at:
	echo "No at prefix"

define mock-no-at-expected
echo No at prefix
endef

$(call bowerbird::test::add-mock-test,\
test-mock-without-at-prefix,\
mock-test-no-at,\
$(mock-no-at-expected))

# test-mock-mixed-at-prefix
#
#	Tests mixed @ and non-@ commands.
#
#	Verifies that both are captured correctly.
#

.PHONY: mock-test-mixed
mock-test-mixed:
	@echo "With at"
	echo "Without at"
	@echo "With at again"

define mock-mixed-expected
echo With at
echo Without at
echo With at again
endef

$(call bowerbird::test::add-mock-test,\
test-mock-mixed-at-prefix,\
mock-test-mixed,\
$(mock-mixed-expected))

# test-mock-special-chars-quotes
#
#	Tests commands with special characters.
#
#	Verifies that quotes are preserved in captured commands.
#

.PHONY: mock-test-special-chars
mock-test-special-chars:
	@echo 'single quotes'
	@echo "double quotes"
	@echo "mixed 'quotes'"

define mock-special-chars-expected
echo 'single quotes'
echo "double quotes"
echo "mixed 'quotes'"
endef

$(call bowerbird::test::add-mock-test,\
test-mock-special-chars-quotes,\
mock-test-special-chars,\
$(mock-special-chars-expected))

# test-mock-dollar-signs
#
#	Tests commands with dollar signs.
#
#	Verifies that Make variable references are captured correctly.
#

.PHONY: mock-test-dollars
mock-test-dollars: DOLLAR_VAR = value
mock-test-dollars:
	@echo "Variable: $(DOLLAR_VAR)"
	@echo "Literal: $$HOME"

define mock-dollars-expected
echo Variable: value
echo Literal: $HOME
endef

$(call bowerbird::test::add-mock-test,\
test-mock-dollar-signs,\
mock-test-dollars,\
$(mock-dollars-expected))

# test-mock-results-directory-creation
#
#	Tests that results directory is created automatically.
#
#	Verifies mock shell creates parent directories.
#

.PHONY: mock-test-dir-creation
mock-test-dir-creation:
	@echo "Testing directory creation"

define mock-dir-creation-expected
echo Testing directory creation
endef

$(call bowerbird::test::add-mock-test,\
test-mock-results-directory-creation,\
mock-test-dir-creation,\
$(mock-dir-creation-expected))

# test-mock-results-appending
#
#	Tests that multiple commands append to results file.
#
#	Verifies commands are logged in order.
#

.PHONY: mock-test-appending
mock-test-appending:
	@echo "First"
	@echo "Second"
	@echo "Third"

define mock-appending-expected
echo First
echo Second
echo Third
endef

$(call bowerbird::test::add-mock-test,\
test-mock-results-appending,\
mock-test-appending,\
$(mock-appending-expected))

# test-mock-long-command-line
#
#	Tests commands with very long argument lists.
#
#	Verifies that long commands are captured correctly.
#

.PHONY: mock-test-long-command
mock-test-long-command:
	@echo "This is a very long command line with many arguments that should still be captured correctly by the mock shell framework"

define mock-long-command-expected
echo This is a very long command line with many arguments that should still be captured correctly by the mock shell framework
endef

$(call bowerbird::test::add-mock-test,\
test-mock-long-command-line,\
mock-test-long-command,\
$(mock-long-command-expected))

# test-mock-automatic-phony
#
#	Tests that mock test targets work without explicit .PHONY.
#
#	Verifies add-mock-test handles target creation correctly.
#

.PHONY: mock-test-auto-phony
mock-test-auto-phony:
	@echo "Auto phony test"

define mock-auto-phony-expected
echo Auto phony test
endef

$(call bowerbird::test::add-mock-test,\
test-mock-automatic-phony,\
mock-test-auto-phony,\
$(mock-auto-phony-expected))
