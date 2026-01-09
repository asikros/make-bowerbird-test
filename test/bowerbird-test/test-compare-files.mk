test-compare-files-equal:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s' "hello world" > $(WORKDIR_TEST)/$@/file1.txt
	@printf '%s' "hello world" > $(WORKDIR_TEST)/$@/file2.txt
	$(call bowerbird::test::compare-files,$(WORKDIR_TEST)/$@/file1.txt,$(WORKDIR_TEST)/$@/file2.txt)


test-compare-files-not-equal:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s' "hello world" > $(WORKDIR_TEST)/$@/file1.txt
	@printf '%s' "goodbye world" > $(WORKDIR_TEST)/$@/file2.txt
	! $(call bowerbird::test::compare-files,$(WORKDIR_TEST)/$@/file1.txt,$(WORKDIR_TEST)/$@/file2.txt)


test-compare-files-missing-first:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s' "content" > $(WORKDIR_TEST)/$@/file2.txt
	! $(call bowerbird::test::compare-files,$(WORKDIR_TEST)/$@/nonexistent.txt,$(WORKDIR_TEST)/$@/file2.txt)


test-compare-files-missing-second:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s' "content" > $(WORKDIR_TEST)/$@/file1.txt
	! $(call bowerbird::test::compare-files,$(WORKDIR_TEST)/$@/file1.txt,$(WORKDIR_TEST)/$@/nonexistent.txt)


test-compare-files-empty-both:
	@mkdir -p $(WORKDIR_TEST)/$@
	@touch $(WORKDIR_TEST)/$@/file1.txt
	@touch $(WORKDIR_TEST)/$@/file2.txt
	$(call bowerbird::test::compare-files,$(WORKDIR_TEST)/$@/file1.txt,$(WORKDIR_TEST)/$@/file2.txt)


test-compare-files-empty-vs-content:
	@mkdir -p $(WORKDIR_TEST)/$@
	@touch $(WORKDIR_TEST)/$@/file1.txt
	@printf '%s' "content" > $(WORKDIR_TEST)/$@/file2.txt
	! $(call bowerbird::test::compare-files,$(WORKDIR_TEST)/$@/file1.txt,$(WORKDIR_TEST)/$@/file2.txt)


test-compare-files-multiline:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf 'line one\nline two\nline three\n' > $(WORKDIR_TEST)/$@/file1.txt
	@printf 'line one\nline two\nline three\n' > $(WORKDIR_TEST)/$@/file2.txt
	$(call bowerbird::test::compare-files,$(WORKDIR_TEST)/$@/file1.txt,$(WORKDIR_TEST)/$@/file2.txt)


test-compare-files-whitespace-diff:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s' "hello world" > $(WORKDIR_TEST)/$@/file1.txt
	@printf '%s' "hello  world" > $(WORKDIR_TEST)/$@/file2.txt
	! $(call bowerbird::test::compare-files,$(WORKDIR_TEST)/$@/file1.txt,$(WORKDIR_TEST)/$@/file2.txt)


test-compare-files-trailing-newline-diff:
	@mkdir -p $(WORKDIR_TEST)/$@
	@printf '%s' "content" > $(WORKDIR_TEST)/$@/file1.txt
	@printf '%s\n' "content" > $(WORKDIR_TEST)/$@/file2.txt
	! $(call bowerbird::test::compare-files,$(WORKDIR_TEST)/$@/file1.txt,$(WORKDIR_TEST)/$@/file2.txt)
