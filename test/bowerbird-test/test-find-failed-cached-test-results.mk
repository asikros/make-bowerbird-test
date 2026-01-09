MOCK_CACHE_DIR = test/mock-tests/cached-results


test-find-failed-cached-test-results-count:
	$(call bowerbird::test::compare-strings,3,$(words $(shell find $(MOCK_CACHE_DIR) -type f -name '*.$(bowerbird-test.constant.ext-fail)')))


test-find-failed-cached-test-results-files:
	$(call bowerbird::test::compare-sets,\
		$(notdir $(shell find $(MOCK_CACHE_DIR) -type f -name '*.$(bowerbird-test.constant.ext-fail)')),\
		test-gamma.fail test-delta.fail test-nested.fail)


test-find-failed-cached-test-results-empty-dir:
	$(call bowerbird::test::compare-strings,0,$(words $(shell find test/mock-tests/empty-dir -type f -name '*.$(bowerbird-test.constant.ext-fail)' 2>/dev/null)))


test-find-failed-cached-test-results-nonexistent-dir:
	$(call bowerbird::test::compare-strings,0,$(words $(shell test -d nonexistent-cache && find nonexistent-cache -type f -name '*.$(bowerbird-test.constant.ext-fail)' 2>/dev/null)))


test-find-failed-cached-test-results-nested:
	$(call bowerbird::test::compare-strings,1,$(words $(shell find $(MOCK_CACHE_DIR)/nested -type f -name '*.$(bowerbird-test.constant.ext-fail)')))
