# Unit tests for basic mock shell functionality

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
