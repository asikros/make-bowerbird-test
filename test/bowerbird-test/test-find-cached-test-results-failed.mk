MOCK_CACHE_DIR = test/mock-tests/cached-results


test-find-cached-test-results-failed-count:
	$(call bowerbird::test::compare-strings,3,$(words $(call bowerbird::test::find-cached-test-results-failed,$(MOCK_CACHE_DIR))))


test-find-cached-test-results-failed-files:
	$(call bowerbird::test::compare-sets,\
		$(call bowerbird::test::find-cached-test-results-failed,$(MOCK_CACHE_DIR)),\
		test-gamma test-delta test-nested)


test-find-cached-test-results-failed-empty-dir:
	$(call bowerbird::test::compare-strings,0,$(words $(call bowerbird::test::find-cached-test-results-failed,test/mock-tests/empty-dir)))


test-find-cached-test-results-failed-nonexistent-dir:
	$(call bowerbird::test::compare-strings,0,$(words $(call bowerbird::test::find-cached-test-results-failed,nonexistent-cache)))


test-find-cached-test-results-failed-nested:
	$(call bowerbird::test::compare-strings,1,$(words $(call bowerbird::test::find-cached-test-results-failed,$(MOCK_CACHE_DIR)/nested)))


test-find-cached-test-results-failed-nested-deep:
	$(call bowerbird::test::compare-strings,0,$(words $(call bowerbird::test::find-cached-test-results-failed,$(MOCK_CACHE_DIR)/nested/deep)))


test-find-cached-test-results-failed-absolute-path:
	$(call bowerbird::test::compare-strings,\
		$(words $(call bowerbird::test::find-cached-test-results-failed,$(abspath $(MOCK_CACHE_DIR)))),\
		$(words $(call bowerbird::test::find-cached-test-results-failed,$(MOCK_CACHE_DIR))))


test-find-cached-test-results-failed-extension-constant:
	$(call bowerbird::test::compare-strings,fail,$(bowerbird-test.constant.ext-fail))


test-find-cached-test-results-failed-path-with-spaces:
	$(call bowerbird::test::compare-strings,0,$(words $(call bowerbird::test::find-cached-test-results-failed,path with spaces)))


test-find-cached-test-results-failed-path-with-special-chars:
	$(call bowerbird::test::compare-strings,0,$(words $(call bowerbird::test::find-cached-test-results-failed,path/with/$$special)))


test-find-cached-test-results-failed-relative-path:
	$(call bowerbird::test::compare-strings,3,$(words $(call bowerbird::test::find-cached-test-results-failed,./$(MOCK_CACHE_DIR))))


test-find-cached-test-results-failed-trailing-slash:
	$(call bowerbird::test::compare-strings,3,$(words $(call bowerbird::test::find-cached-test-results-failed,$(MOCK_CACHE_DIR)/)))


test-find-cached-test-results-failed-returns-target-names-only:
	@result=$$(call bowerbird::test::find-cached-test-results-failed,$(MOCK_CACHE_DIR)); \
	test -z "$$(echo $$result | grep '\.fail')"


# Error message tests - Make-generated errors require recursive make

test-find-cached-test-results-failed-error-no-path:
	@output=$$(printf '%s\n' \
		'include src/bowerbird-test/bowerbird-find.mk' \
		'WORKDIR_TEST=$(WORKDIR_TEST)' \
		'$$(call bowerbird::test::find-cached-test-results-failed,)' \
		'test:' \
		'	@echo done' | \
		$(MAKE) --no-print-directory -f - test 2>&1 || true); \
		echo "$$output" | grep -q "ERROR: bowerbird::test::find-cached-test-results-failed, no path specified"
