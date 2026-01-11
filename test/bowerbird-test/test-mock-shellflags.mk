.PHONY: mock-shellflags-target
mock-shellflags-target:
	@echo "test output"
	@mkdir -p /tmp/test
	@echo "second command"

define mock-shellflags-expected
echo "test output"
mkdir -p /tmp/test
echo "second command"
endef


$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-default,\
	mock-shellflags-target,\
	mock-shellflags-expected,\
	.SHELLFLAGS=-c)


$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-multiple-flags,\
	mock-shellflags-target,\
	mock-shellflags-expected,\
	.SHELLFLAGS="-e -u -c")


$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-combined,\
	mock-shellflags-target,\
	mock-shellflags-expected,\
	.SHELLFLAGS=-xc)


$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-errexit-nounset,\
	mock-shellflags-target,\
	mock-shellflags-expected,\
	.SHELLFLAGS="-e -u -c")


$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-verbose,\
	mock-shellflags-target,\
	mock-shellflags-expected,\
	.SHELLFLAGS="-v -x -c")


$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-many-flags,\
	mock-shellflags-target,\
	mock-shellflags-expected,\
	.SHELLFLAGS="-e -u -x -v -c")


$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-euc-combined,\
	mock-shellflags-target,\
	mock-shellflags-expected,\
	.SHELLFLAGS=-euc)


.PHONY: mock-shellflags-single
mock-shellflags-single:
	@echo "single"

define mock-shellflags-single-expected
echo "single"
endef

$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-single-command,\
	mock-shellflags-single,\
	mock-shellflags-single-expected,\
	.SHELLFLAGS="-e -u -c")


.PHONY: mock-shellflags-vars
mock-shellflags-vars: TEST_VAR = testvalue
mock-shellflags-vars:
	@echo "Variable: $(TEST_VAR)"

define mock-shellflags-vars-expected
echo "Variable: testvalue"
endef

$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-with-variables,\
	mock-shellflags-vars,\
	mock-shellflags-vars-expected,\
	.SHELLFLAGS="-e -u -c")


.PHONY: mock-shellflags-special
mock-shellflags-special:
	@echo "double quotes work"
	@echo "with spaces and tabs"

define mock-shellflags-special-expected
echo "double quotes work"
echo "with spaces and tabs"
endef

$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-special-chars,\
	mock-shellflags-special,\
	mock-shellflags-special-expected,\
	.SHELLFLAGS="-e -c")
