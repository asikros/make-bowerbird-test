MOCK_CACHE_DIR = test/mock-tests/cached-results


test-find-cached-test-results-failed-count:
	$(call bowerbird::test::compare-strings,3,$(words $(shell find $(MOCK_CACHE_DIR) -type f -name '*.$(bowerbird-test.constant.ext-fail)')))


test-find-cached-test-results-failed-files:
	$(call bowerbird::test::compare-sets,\
		$(notdir $(shell find $(MOCK_CACHE_DIR) -type f -name '*.$(bowerbird-test.constant.ext-fail)')),\
		test-gamma.fail test-delta.fail test-nested.fail)


test-find-cached-test-results-failed-empty-dir:
	$(call bowerbird::test::compare-strings,0,$(words $(shell find test/mock-tests/empty-dir -type f -name '*.$(bowerbird-test.constant.ext-fail)' 2>/dev/null)))


test-find-cached-test-results-failed-nonexistent-dir:
	$(call bowerbird::test::compare-strings,0,$(words $(shell test -d nonexistent-cache && find nonexistent-cache -type f -name '*.$(bowerbird-test.constant.ext-fail)' 2>/dev/null)))


test-find-cached-test-results-failed-nested:
	$(call bowerbird::test::compare-strings,1,$(words $(shell find $(MOCK_CACHE_DIR)/nested -type f -name '*.$(bowerbird-test.constant.ext-fail)')))


test-find-cached-test-results-failed-nested-deep:
	$(call bowerbird::test::compare-strings,0,$(words $(shell find $(MOCK_CACHE_DIR)/nested/deep -type f -name '*.$(bowerbird-test.constant.ext-fail)')))


test-find-cached-test-results-failed-absolute-path:
	$(call bowerbird::test::compare-strings,\
		$(words $(shell find $(abspath $(MOCK_CACHE_DIR)) -type f -name '*.$(bowerbird-test.constant.ext-fail)')),\
		$(words $(shell find $(MOCK_CACHE_DIR) -type f -name '*.$(bowerbird-test.constant.ext-fail)')))


test-find-cached-test-results-failed-extension-constant:
	$(call bowerbird::test::compare-strings,fail,$(bowerbird-test.constant.ext-fail))
