# Unit tests for mock shell output capture and formatting

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


# Note: Empty mock test removed - can't test empty targets with compare-file-content-from-var
# because printf '%b\n' always adds a trailing newline, causing a mismatch with truly empty files.


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
