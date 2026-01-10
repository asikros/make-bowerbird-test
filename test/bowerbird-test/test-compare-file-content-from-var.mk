# Tests for bowerbird::test::compare-file-content-from-var
#
# This macro is used in production code (bowerbird-mock.mk) to compare file
# contents against expected values stored in variables. It works around Make's
# limitation with multiline content in $(call ...) within $(eval ...).


# Basic functionality tests

define expected-hello
hello world
endef

test-compare-file-content-from-var-match:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s\n' "hello world" > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/test.txt,expected-hello)


define expected-goodbye
goodbye world
endef

test-compare-file-content-from-var-mismatch:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s\n' "hello world" > $(WORKDIR_TEST)/$@/test.txt
	! ($(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/test.txt,expected-goodbye))


define expected-any
any content
endef

test-compare-file-content-from-var-missing-file:
	! ($(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/nonexistent.txt,expected-any))


# Multiline content tests

define expected-multiline
line one
line two
line three
endef

test-compare-file-content-from-var-multiline:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf 'line one\nline two\nline three\n' > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/test.txt,expected-multiline)


define expected-empty
endef

test-compare-file-content-from-var-empty:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '\n' > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/test.txt,expected-empty)


define expected-content
content
endef

test-compare-file-content-from-var-empty-expected-mismatch:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s\n' "content" > $(WORKDIR_TEST)/$@/test.txt
	! ($(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/test.txt,expected-empty))


# Whitespace tests

define expected-spaces
   
endef

test-compare-file-content-from-var-whitespace-only:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '   \n' > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/test.txt,expected-spaces)


define expected-hello-single-space
hello world
endef

define expected-hello-double-space
hello  world
endef

test-compare-file-content-from-var-whitespace-diff:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s\n' "hello world" > $(WORKDIR_TEST)/$@/test.txt
	! ($(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/test.txt,expected-hello-double-space))


# Special character tests

define expected-special
special @ # chars
endef

test-compare-file-content-from-var-special-chars:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s\n' 'special @ # chars' > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/test.txt,expected-special)


define expected-long
This is a very long string that spans multiple lines
endef

test-compare-file-content-from-var-long-content:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s\n' "This is a very long string that spans multiple lines" > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/test.txt,expected-long)


define expected-tabs
hello	world
endef

test-compare-file-content-from-var-tabs:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf 'hello\tworld\n' > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/test.txt,expected-tabs)


# Mock test simulation - this is the real-world use case

define mock-expected-commands
echo "test command 1"
echo "test command 2"
mkdir -p /tmp/test
endef

test-compare-file-content-from-var-mock-simulation:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s\n' 'echo "test command 1"' 'echo "test command 2"' 'mkdir -p /tmp/test' > $(WORKDIR_TEST)/$@/results.txt
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results.txt,mock-expected-commands)


# Error message tests

define expected-actual-content
actual content
endef

define expected-different
expected content
endef

test-compare-file-content-from-var-error-message:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s\n' 'actual content' > $(WORKDIR_TEST)/$@/test.txt
	@output=$$($(call bowerbird::test::compare-file-content-from-var,\
		$(WORKDIR_TEST)/$@/test.txt,\
		expected-different) 2>&1 || true); \
		echo "$$output" | grep -q "ERROR: Content mismatch for"


define expected-foo
foo
endef

define expected-bar
bar
endef

test-compare-file-content-from-var-error-to-stderr:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s\n' 'foo' > $(WORKDIR_TEST)/$@/test.txt
	@output=$$($(call bowerbird::test::compare-file-content-from-var,\
		$(WORKDIR_TEST)/$@/test.txt,\
		expected-bar) 2>&1 || true); \
		test -n "$$output"


define expected-a
a
endef

define expected-b
b
endef

test-compare-file-content-from-var-error-has-prefix:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s\n' 'a' > $(WORKDIR_TEST)/$@/test.txt
	@output=$$($(call bowerbird::test::compare-file-content-from-var,\
		$(WORKDIR_TEST)/$@/test.txt,\
		expected-b) 2>&1 || true); \
		echo "$$output" | grep -q "^ERROR:"
