# test-compare-file-content-match
#
#	Tests compare-file-content with matching content.
#
#	Verifies that comparison succeeds when file content matches expected string.
#

test-compare-file-content-match:
	@mkdir -p $(WORKDIR_TEST)/$@
	@echo -n "hello world" > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/test.txt,\
		hello world)

# test-compare-file-content-mismatch
#
#	Tests compare-file-content with mismatched content.
#
#	Raises:
#		ERROR: Failed string comparison when content doesn't match.
#

test-compare-file-content-mismatch:
	@mkdir -p $(WORKDIR_TEST)/$@
	@echo -n "hello world" > $(WORKDIR_TEST)/$@/test.txt
	! $(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/test.txt,\
		goodbye world)

# test-compare-file-content-missing
#
#	Tests compare-file-content with missing file.
#
#	Raises:
#		ERROR: Results file not found when file doesn't exist.
#

test-compare-file-content-missing:
	! $(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/nonexistent.txt,\
		any content)

# test-compare-file-content-multiline
#
#	Tests compare-file-content with multi-line content.
#
#	Verifies that newlines are handled correctly.
#

define multiline-expected
line one
line two
line three
endef

test-compare-file-content-multiline:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf "line one\nline two\nline three" > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/test.txt,\
		$(multiline-expected))

# test-compare-file-content-empty-file
#
#	Tests compare-file-content with empty file.
#
#	Verifies that empty file matches empty expected string.
#

test-compare-file-content-empty-file:
	@mkdir -p $(WORKDIR_TEST)/$@
	@touch $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/test.txt,\
		)

# test-compare-file-content-empty-expected
#
#	Tests compare-file-content with empty expected string.
#
#	Verifies that non-empty file fails against empty expected.
#

test-compare-file-content-empty-expected:
	@mkdir -p $(WORKDIR_TEST)/$@
	@echo -n "content" > $(WORKDIR_TEST)/$@/test.txt
	! $(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/test.txt,\
		)

# test-compare-file-content-whitespace-only
#
#	Tests compare-file-content with whitespace-only content.
#
#	Verifies that whitespace is significant in comparison.
#

test-compare-file-content-whitespace-only:
	@mkdir -p $(WORKDIR_TEST)/$@
	@echo -n "   " > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/test.txt,\
		   )

# test-compare-file-content-whitespace-diff
#
#	Tests compare-file-content with whitespace differences.
#
#	Raises:
#		ERROR: Failed string comparison for whitespace differences.
#

test-compare-file-content-whitespace-diff:
	@mkdir -p $(WORKDIR_TEST)/$@
	@echo -n "hello world" > $(WORKDIR_TEST)/$@/test.txt
	! $(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/test.txt,\
		hello  world)

# test-compare-file-content-trailing-newline
#
#	Tests compare-file-content with trailing newline.
#
#	Raises:
#		ERROR: Failed string comparison when newline differs.
#

test-compare-file-content-trailing-newline:
	@mkdir -p $(WORKDIR_TEST)/$@
	@echo "content" > $(WORKDIR_TEST)/$@/test.txt
	! $(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/test.txt,\
		content)

# test-compare-file-content-no-trailing-newline
#
#	Tests compare-file-content without trailing newline.
#
#	Verifies exact match without trailing newline.
#

test-compare-file-content-no-trailing-newline:
	@mkdir -p $(WORKDIR_TEST)/$@
	@echo -n "content" > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/test.txt,\
		content)

# test-compare-file-content-special-chars
#
#	Tests compare-file-content with special characters.
#
#	Verifies that special characters are handled correctly.
#

test-compare-file-content-special-chars:
	@mkdir -p $(WORKDIR_TEST)/$@
	@echo -n 'special: $$ @ # %' > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/test.txt,\
		special: $$ @ # %)

# test-compare-file-content-long-content
#
#	Tests compare-file-content with long content.
#
#	Verifies that long strings are compared correctly.
#

define long-expected
This is a very long string that spans multiple conceptual lines but is actually one long line that tests whether the comparison can handle large amounts of text content without any issues
endef

test-compare-file-content-long-content:
	@mkdir -p $(WORKDIR_TEST)/$@
	@echo -n "This is a very long string that spans multiple conceptual lines but is actually one long line that tests whether the comparison can handle large amounts of text content without any issues" > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/test.txt,\
		$(long-expected))
