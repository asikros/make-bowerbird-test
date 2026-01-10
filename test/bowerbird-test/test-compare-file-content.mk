test-compare-file-content-match:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s' "hello world" > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,$(WORKDIR_TEST)/$@/test.txt,hello world)


test-compare-file-content-mismatch:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s' "hello world" > $(WORKDIR_TEST)/$@/test.txt
	! ($(call bowerbird::test::compare-file-content,$(WORKDIR_TEST)/$@/test.txt,goodbye world))


test-compare-file-content-missing:
	! ($(call bowerbird::test::compare-file-content,$(WORKDIR_TEST)/$@/nonexistent.txt,any content))


test-compare-file-content-multiline-escape:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf 'line one\nline two\nline three' > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,$(WORKDIR_TEST)/$@/test.txt,line one\nline two\nline three)


define multiline-expected
line one
line two
line three
endef

test-compare-file-content-multiline-define:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf 'line one\nline two\nline three' > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,$(WORKDIR_TEST)/$@/test.txt,$(multiline-expected))


test-compare-file-content-empty-file:
	@mkdir -p $(WORKDIR_TEST)/$@
	@touch $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,$(WORKDIR_TEST)/$@/test.txt,)


test-compare-file-content-empty-expected:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s' "content" > $(WORKDIR_TEST)/$@/test.txt
	! ($(call bowerbird::test::compare-file-content,$(WORKDIR_TEST)/$@/test.txt,))


test-compare-file-content-whitespace-only:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s' "   " > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,$(WORKDIR_TEST)/$@/test.txt,   )


test-compare-file-content-whitespace-diff:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s' "hello world" > $(WORKDIR_TEST)/$@/test.txt
	! ($(call bowerbird::test::compare-file-content,$(WORKDIR_TEST)/$@/test.txt,hello  world))


test-compare-file-content-trailing-newline:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s\n' "content" > $(WORKDIR_TEST)/$@/test.txt
	! ($(call bowerbird::test::compare-file-content,$(WORKDIR_TEST)/$@/test.txt,content))


test-compare-file-content-no-trailing-newline:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s' "content" > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,$(WORKDIR_TEST)/$@/test.txt,content)


test-compare-file-content-special-chars:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s' 'special @ # chars' > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,$(WORKDIR_TEST)/$@/test.txt,special @ # chars)


test-compare-file-content-long-content:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s' "This is a very long string that spans multiple lines" > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,$(WORKDIR_TEST)/$@/test.txt,This is a very long string that spans multiple lines)


test-compare-file-content-tabs:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf 'hello\tworld' > $(WORKDIR_TEST)/$@/test.txt
	$(call bowerbird::test::compare-file-content,$(WORKDIR_TEST)/$@/test.txt,hello\tworld)


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


test-compare-file-content-error-has-prefix:
	@mkdir -p $(WORKDIR_TEST)/$@
	@echo a > $(WORKDIR_TEST)/$@/test.txt
	@output=$$($(call bowerbird::test::compare-file-content,\
		$(WORKDIR_TEST)/$@/test.txt,b) 2>&1 || true); \
		echo "$$output" | grep -q "^ERROR:"
