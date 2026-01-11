# Proposal: Pattern-Based Test Execution

**Status:** Draft
**Author:** System
**Date:** 2026-01-10

## Problem

Test suite generation is slow due to generating individual explicit targets for each test. For 226 tests, we generate ~4,975 lines of nearly identical Make code (~22 lines per test).

**Current Performance:**
- Generated file size: 4,975 lines
- Generation time: Slow (noticeable lag)
- Parse time: Slow (Make must parse thousands of lines)
- Memory usage: High (thousands of rules in memory)

**Example of current generated code (20+ lines per test):**
```makefile
.PHONY: __test-wrapper/private_test/test-compare-strings-equal
__test-wrapper/private_test/test-compare-strings-equal:
	@mkdir -p $(dir /path/to/logs/test-compare-strings-equal.log)
	@($(MAKE) test-compare-strings-equal --debug=v --warn-undefined-variables TAG=123 \
			>/path/to/logs/test-compare-strings-equal.log 2>&1 && \
			(! (grep -v "grep.*warning: undefined variable" \
					/path/to/logs/test-compare-strings-equal.log | \
					grep --color=always "^.*warning: undefined variable.*$$" \
					>> /path/to/logs/test-compare-strings-equal.log) || exit 1) && \
			( \
				printf "\e[1;32mPassed:\e[0m test-compare-strings-equal\n" && \
				printf "\e[1;32mPassed:\e[0m test-compare-strings-equal\n" > /path/to/results/test-compare-strings-equal.pass \
			)) || \
		(\
			printf "\e[1;31mFailed: test-compare-strings-equal\e[0m\n" && \
			printf "\e[1;31mFailed: test-compare-strings-equal\e[0m\n" > /path/to/results/test-compare-strings-equal.fail && \
				echo && cat /path/to/logs/test-compare-strings-equal.log >&2 && \
				echo && printf "\e[1;31mFailed: test-compare-strings-equal\e[0m\n" >&2 && \
					(test 0 -eq 0 || (kill -TERM $$(pgrep -f TAG=123))) && \
					exit 1 \
		)
```

This repeats for every single test with only the test name changing!

## Proposed Solution

Use a **single pattern rule** with automatic variables instead of generating individual targets.

### Optimized Generated File Structure

```makefile
# Auto-generated test execution rules for suite: private_test

# Suite-specific variables
BOWERBIRD_TEST/SUITE/private_test/workdir-logs := /path/to/.bowerbird/private_test
BOWERBIRD_TEST/SUITE/private_test/workdir-results := /path/to/.bowerbird/private_test
BOWERBIRD_TEST/SUITE/private_test/process-tag := __BOWERBIRD_TEST_PROCESS_TAG__=12345
BOWERBIRD_TEST/SUITE/private_test/fail-fast := 0
BOWERBIRD_TEST/SUITE/private_test/fail-exit-code := 1

# Pattern rule handles ALL test wrapper targets
# $* = test name (e.g., "test-compare-strings-equal")
__test-wrapper/private_test/%:
	@mkdir -p $(dir $(BOWERBIRD_TEST/SUITE/private_test/workdir-logs)/$*.log)
	@($(MAKE) $* --debug=v --warn-undefined-variables $(BOWERBIRD_TEST/SUITE/private_test/process-tag) \
			>$(BOWERBIRD_TEST/SUITE/private_test/workdir-logs)/$*.log 2>&1 && \
			(! (grep -v "grep.*warning: undefined variable" \
					$(BOWERBIRD_TEST/SUITE/private_test/workdir-logs)/$*.log | \
					grep --color=always "^.*warning: undefined variable.*$$" \
					>> $(BOWERBIRD_TEST/SUITE/private_test/workdir-logs)/$*.log) || exit $(BOWERBIRD_TEST/SUITE/private_test/fail-exit-code)) && \
			( \
				printf "\e[1;32mPassed:\e[0m $*\n" && \
				printf "\e[1;32mPassed:\e[0m $*\n" > $(BOWERBIRD_TEST/SUITE/private_test/workdir-results)/$*.pass \
			)) || \
		(\
			printf "\e[1;31mFailed: $*\e[0m\n" && \
			printf "\e[1;31mFailed: $*\e[0m\n" > $(BOWERBIRD_TEST/SUITE/private_test/workdir-results)/$*.fail && \
				echo && cat $(BOWERBIRD_TEST/SUITE/private_test/workdir-logs)/$*.log >&2 && \
				echo && printf "\e[1;31mFailed: $*\e[0m\n" >&2 && \
					(test $(BOWERBIRD_TEST/SUITE/private_test/fail-fast) -eq 0 || (kill -TERM $$(pgrep -f $(BOWERBIRD_TEST/SUITE/private_test/process-tag)))) && \
					exit $(BOWERBIRD_TEST/SUITE/private_test/fail-exit-code) \
		)
```

**Total lines:** ~30 lines (vs. 4,975 lines)

### Key Improvements

1. **Massive File Size Reduction**
   - Before: ~4,975 lines (22 lines × 226 tests)
   - After: ~30 lines (1 pattern rule + 5 variables)
   - **Reduction: 99.4%**

2. **Faster Generation**
   - Before: Loop through 226 tests, echo 22 lines each = 4,972 shell commands
   - After: Echo ~30 lines total = 30 shell commands
   - **Speedup: ~165x**

3. **Faster Parsing**
   - Before: Make parses 4,975 lines defining 226 explicit rules
   - After: Make parses 30 lines defining 1 pattern rule
   - **Speedup: ~165x**

4. **Lower Memory Usage**
   - Before: 226 explicit rules in Make's internal database
   - After: 1 pattern rule + 5 variables
   - **Reduction: ~98%**

5. **Easier to Maintain**
   - Single source of truth for test execution logic
   - Changes to test execution require updating 1 rule, not regenerating thousands of lines

## Implementation Strategy

### Phase 1: Update Generation Logic

Modify `bowerbird::test::__suite-generate-rules` in `bowerbird-suite.mk`:

```makefile
define bowerbird::test::__suite-generate-rules # output-file, suite-name
	@echo "# Auto-generated test execution rules for suite: $2" >> $1
	@echo "" >> $1
	@echo "# Suite-specific variables" >> $1
	@echo "BOWERBIRD_TEST/SUITE/$2/workdir-logs := $(bowerbird-test.constant.workdir-logs)/$2" >> $1
	@echo "BOWERBIRD_TEST/SUITE/$2/workdir-results := $(bowerbird-test.constant.workdir-results)/$2" >> $1
	@echo "BOWERBIRD_TEST/SUITE/$2/process-tag := $(bowerbird-test.constant.process-tag)" >> $1
	@echo "BOWERBIRD_TEST/SUITE/$2/fail-fast := $(bowerbird-test.option.fail-fast)" >> $1
	@echo "BOWERBIRD_TEST/SUITE/$2/fail-exit-code := $(bowerbird-test.constant.fail-exit-code)" >> $1
	@echo "" >> $1
	@echo "# Pattern rule handles ALL test wrapper targets" >> $1
	@echo "# \$$* = test name (e.g., \"test-compare-strings-equal\")" >> $1
	@echo "__test-wrapper/$2/%:" >> $1
	@echo "	@mkdir -p \$$(dir \$$(BOWERBIRD_TEST/SUITE/$2/workdir-logs)/\$$*.log)" >> $1
	@echo "	@(\$$(MAKE) \$$* --debug=v --warn-undefined-variables \$$(BOWERBIRD_TEST/SUITE/$2/process-tag) \\" >> $1
	@echo "			>\$$(BOWERBIRD_TEST/SUITE/$2/workdir-logs)/\$$*.log 2>&1 && \\" >> $1
	@echo "			(! (grep -v \"grep.*$(bowerbird-test.constant.undefined-variable-warning)\" \\" >> $1
	@echo "					\$$(BOWERBIRD_TEST/SUITE/$2/workdir-logs)/\$$*.log | \\" >> $1
	@echo "					grep --color=always \"^.*$(bowerbird-test.constant.undefined-variable-warning).*\$$\$$\$$\$$\" \\" >> $1
	@echo "					>> \$$(BOWERBIRD_TEST/SUITE/$2/workdir-logs)/\$$*.log) || exit \$$(BOWERBIRD_TEST/SUITE/$2/fail-exit-code)) && \\" >> $1
	@echo "			( \\" >> $1
	@echo "				printf \"\e[1;32mPassed:\e[0m \$$*\n\" && \\" >> $1
	@echo "				printf \"\e[1;32mPassed:\e[0m \$$*\n\" > \$$(BOWERBIRD_TEST/SUITE/$2/workdir-results)/\$$*.pass \\" >> $1
	@echo "			)) || \\" >> $1
	@echo "		(\\" >> $1
	@echo "			printf \"\e[1;31mFailed: \$$*\e[0m\n\" && \\" >> $1
	@echo "			printf \"\e[1;31mFailed: \$$*\e[0m\n\" > \$$(BOWERBIRD_TEST/SUITE/$2/workdir-results)/\$$*.fail && \\" >> $1
	@echo "				echo && cat \$$(BOWERBIRD_TEST/SUITE/$2/workdir-logs)/\$$*.log >&2 && \\" >> $1
	@echo "				echo && printf \"\e[1;31mFailed: \$$*\e[0m\n\" >&2 && \\" >> $1
	@echo "					(test \$$(BOWERBIRD_TEST/SUITE/$2/fail-fast) -eq 0 || (kill -TERM \$$\$$\$$\$$\$$(pgrep -f \$$(BOWERBIRD_TEST/SUITE/$2/process-tag)))) && \\" >> $1
	@echo "					exit \$$(BOWERBIRD_TEST/SUITE/$2/fail-exit-code) \\" >> $1
	@echo "		)" >> $1
endef
```

### Phase 2: Testing

1. Run full test suite to ensure no regressions
2. Verify fail-fast still works correctly
3. Verify fail-first still works correctly
4. Verify undefined variable detection still works
5. Measure performance improvements

### Phase 3: Benchmarking

Create a benchmark to measure:
- Generation time (old vs. new)
- Parse time (old vs. new)
- Total test execution time (should be identical)
- File size (old vs. new)

## Compatibility

- **Make Version:** Requires Make 3.81+ (pattern rules with `%` - already a requirement)
- **Behavior:** Identical test execution behavior
- **API:** No changes to `bowerbird::test::suite` macro
- **Migration:** Zero migration required - users see faster performance immediately

## Risks

1. **Dollar Sign Escaping Complexity**
   - Pattern rules require careful `$` escaping in generated code
   - Mitigation: Thorough testing with existing 226 tests

2. **Debugging**
   - Harder to see individual rules with `make -p`
   - Mitigation: Pattern rule is simple and well-documented

3. **Edge Cases**
   - Test names with special characters might behave differently
   - Mitigation: Current tests include special characters - validate they still work

## Success Criteria

- ✅ All 226 tests pass
- ✅ Fail-fast functionality preserved
- ✅ Fail-first functionality preserved
- ✅ Undefined variable detection preserved
- ✅ Generated file < 50 lines (vs. 4,975)
- ✅ Generation time < 10ms (vs. current time)
- ✅ Parse time < 10ms (vs. current time)

## Future Enhancements

Once pattern-based execution is working:

1. **Remove file generation entirely**
   - Define pattern rule directly in `bowerbird-suite.mk`
   - Pass suite-specific variables via target-specific variables
   - Eliminate disk I/O completely

2. **Parallel test execution optimization**
   - Pattern rules make parallelization more efficient
   - Make's jobserver can better manage parallel test execution

## References

- GNU Make Manual: [Pattern Rules](https://www.gnu.org/software/make/manual/html_node/Pattern-Rules.html)
- GNU Make Manual: [Automatic Variables](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html)
- Current implementation: `bowerbird-suite.mk:263-292`
