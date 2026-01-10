# Tests for error messages from all compare macros
#
# These tests verify that the correct error messages are output when comparisons fail.


# compare-strings error message tests

test-compare-strings-error-message:
	@mkdir -p $(WORKDIR_TEST)/$@
	@output=$$($(call bowerbird::test::compare-strings,actual,expected) 2>&1 || true); \
		echo "$$output" | grep -q "ERROR: Failed string comparison: 'actual' != 'expected'"


test-compare-strings-error-to-stderr:
	@mkdir -p $(WORKDIR_TEST)/$@
	@output=$$($(call bowerbird::test::compare-strings,foo,bar) 2>&1 || true); \
		test -n "$$output"


# compare-sets error message tests

test-compare-sets-error-message:
	@mkdir -p $(WORKDIR_TEST)/$@
	@output=$$($(call bowerbird::test::compare-sets,alpha beta,gamma delta) 2>&1 || true); \
		echo "$$output" | grep -q "ERROR: Failed list comparison: 'alpha beta' != 'delta gamma'"


test-compare-sets-error-to-stderr:
	@mkdir -p $(WORKDIR_TEST)/$@
	@output=$$($(call bowerbird::test::compare-sets,one,two) 2>&1 || true); \
		test -n "$$output"


# compare-files error message tests

test-compare-files-error-message:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf 'content1' > $(WORKDIR_TEST)/$@/file1.txt
	@printf 'content2' > $(WORKDIR_TEST)/$@/file2.txt
	@output=$$($(call bowerbird::test::compare-files,\
		$(WORKDIR_TEST)/$@/file1.txt,\
		$(WORKDIR_TEST)/$@/file2.txt) 2>&1 || true); \
		echo "$$output" | grep -q "ERROR: Failed file comparison:"


test-compare-files-error-to-stderr:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf 'foo' > $(WORKDIR_TEST)/$@/file1.txt
	@printf 'bar' > $(WORKDIR_TEST)/$@/file2.txt
	@output=$$($(call bowerbird::test::compare-files,\
		$(WORKDIR_TEST)/$@/file1.txt,\
		$(WORKDIR_TEST)/$@/file2.txt) 2>&1 || true); \
		test -n "$$output"


# compare-file-content error message tests

test-compare-file-content-error-message:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf 'actual content' > $(WORKDIR_TEST)/$@/test.txt
	@output=$$($(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/test.txt,\
		expected content) 2>&1 || true); \
		echo "$$output" | grep -q "ERROR: Content mismatch for"


test-compare-file-content-error-to-stderr:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf 'actual' > $(WORKDIR_TEST)/$@/test.txt
	@output=$$($(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/test.txt,\
		expected) 2>&1 || true); \
		test -n "$$output"


# Test that all error messages contain "ERROR:" prefix

test-compare-strings-error-has-prefix:
	@output=$$($(call bowerbird::test::compare-strings,a,b) 2>&1 || true); \
		echo "$$output" | grep -q "^ERROR:"


test-compare-sets-error-has-prefix:
	@output=$$($(call bowerbird::test::compare-sets,a,b) 2>&1 || true); \
		echo "$$output" | grep -q "^ERROR:"


test-compare-files-error-has-prefix:
	@mkdir -p $(WORKDIR_TEST)/$@
	@echo a > $(WORKDIR_TEST)/$@/f1
	@echo b > $(WORKDIR_TEST)/$@/f2
	@output=$$($(call bowerbird::test::compare-files,\
		$(WORKDIR_TEST)/$@/f1,\
		$(WORKDIR_TEST)/$@/f2) 2>&1 || true); \
		echo "$$output" | grep -q "^ERROR:"


test-compare-file-content-error-has-prefix:
	@mkdir -p $(WORKDIR_TEST)/$@
	@echo a > $(WORKDIR_TEST)/$@/test.txt
	@output=$$($(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/test.txt,b) 2>&1 || true); \
		echo "$$output" | grep -q "^ERROR:"
