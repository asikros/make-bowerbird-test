MOCK_CACHE_DIR = test/mock-tests/cached-results

test-find-cached-test-results-pass-count:
	$(call bowerbird::test::compare-strings,3,$(words $(shell find $(MOCK_CACHE_DIR) -type f -name '*.pass')))

test-find-cached-test-results-pass-files:
	$(call bowerbird::test::compare-sets,\
		$(notdir $(shell find $(MOCK_CACHE_DIR) -type f -name '*.pass')),\
		test-alpha.pass test-beta.pass test-deep.pass)

test-find-cached-test-results-fail-count:
	$(call bowerbird::test::compare-strings,3,$(words $(shell find $(MOCK_CACHE_DIR) -type f -name '*.fail')))

test-find-cached-test-results-fail-files:
	$(call bowerbird::test::compare-sets,\
		$(notdir $(shell find $(MOCK_CACHE_DIR) -type f -name '*.fail')),\
		test-gamma.fail test-delta.fail test-nested.fail)

test-find-cached-test-results-no-match:
	$(call bowerbird::test::compare-strings,0,$(words $(shell find $(MOCK_CACHE_DIR) -type f -name '*.nomatch' 2>/dev/null)))

test-find-cached-test-results-nonexistent-dir:
	$(call bowerbird::test::compare-strings,0,$(words $(shell test -d nonexistent-cache && find nonexistent-cache -type f -name '*.pass' 2>/dev/null)))

test-find-cached-test-results-empty-dir:
	$(call bowerbird::test::compare-strings,0,$(words $(shell find test/mock-tests/empty-dir -type f -name '*.pass' 2>/dev/null)))

test-find-cached-test-results-nested-dirs:
	$(call bowerbird::test::compare-strings,1,$(words $(shell find $(MOCK_CACHE_DIR)/nested/deep -type f -name '*.pass')))

test-find-cached-test-results-excludes-similar-ext:
	$(call bowerbird::test::compare-strings,0,$(words $(filter %.bak,$(shell find $(MOCK_CACHE_DIR) -type f -name '*.pass'))))
