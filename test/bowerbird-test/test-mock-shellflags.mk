.PHONY: mock-shellflags-target
mock-shellflags-target:
	@echo "test output"
	@mkdir -p /tmp/test
	@echo "second command"
	@echo "multiline" && \
		echo "continuation"

define mock-shellflags-expected
echo "test output"
mkdir -p /tmp/test
echo "second command"
echo "multiline" && 	echo "continuation"
endef


$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-default,\
	mock-shellflags-target,\
	mock-shellflags-expected,)


# Test that .SHELLFLAGS passes through correctly by showing SHELL output
define mock-shellflags-show-expected
/bin/sh -e -u -c echo "test output"
/bin/sh -e -u -c mkdir -p /tmp/test
/bin/sh -e -u -c echo "second command"
/bin/sh -e -u -c echo "multiline" && 	echo "continuation"
endef

$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-multiple-flags,\
	mock-shellflags-target,\
	mock-shellflags-show-expected,\
	__BOWERBIRD_MOCK_SHOW_SHELL= .SHELLFLAGS="-e -u -c")


define mock-shellflags-combined-show-expected
/bin/sh -xc echo "test output"
/bin/sh -xc mkdir -p /tmp/test
/bin/sh -xc echo "second command"
/bin/sh -xc echo "multiline" && 	echo "continuation"
endef

$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-combined,\
	mock-shellflags-target,\
	mock-shellflags-combined-show-expected,\
	__BOWERBIRD_MOCK_SHOW_SHELL= .SHELLFLAGS=-xc)


# Test basic command capture without showing shell
$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-errexit-nounset,\
	mock-shellflags-target,\
	mock-shellflags-expected,)


$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-verbose,\
	mock-shellflags-target,\
	mock-shellflags-expected,)


$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-many-flags,\
	mock-shellflags-target,\
	mock-shellflags-expected,)


define mock-shellflags-euc-show-expected
/bin/sh -euc echo "test output"
/bin/sh -euc mkdir -p /tmp/test
/bin/sh -euc echo "second command"
/bin/sh -euc echo "multiline" && 	echo "continuation"
endef

$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-euc-combined,\
	mock-shellflags-target,\
	mock-shellflags-euc-show-expected,\
	__BOWERBIRD_MOCK_SHOW_SHELL= .SHELLFLAGS=-euc)


.PHONY: mock-shellflags-single
mock-shellflags-single:
	@echo "single"

define mock-shellflags-single-expected
echo "single"
endef

$(call bowerbird::test::add-mock-test,\
	test-mock-shellflags-single-command,\
	mock-shellflags-single,\
	mock-shellflags-single-expected,)


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
	mock-shellflags-vars-expected,)


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
	mock-shellflags-special-expected,)
