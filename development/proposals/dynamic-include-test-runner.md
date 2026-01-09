# Proposal: Dynamic Include-Based Test Runner

## Problem Statement

The current test runner uses recursive Make extensively:
```makefile
$(MAKE) test-foo --debug=v --warn-undefined-variables >test-foo.log 2>&1
```

While this provides excellent test isolation, it has performance implications:
- Each test spawns a new Make subprocess (~50ms overhead per test)
- For a suite with 255 tests: ~12.75 seconds of pure overhead
- Cannot leverage Make's parallel execution efficiently

## Proposed Solution: Dynamic Include Files

Use Make's automatic re-execution feature to generate test rules on-the-fly instead of using recursive Make.

### How Make's Auto Re-execution Works

When Make encounters a rule that generates an included file, it:
1. **First pass**: Generates the .mk file
2. **Detects** the new/updated include file
3. **Re-executes** itself with the new rules loaded
4. **Second pass**: Runs normally with generated rules available

### Architecture

```
┌─────────────────────────────────────────┐
│ User Makefile                           │
│ $(call bowerbird::test::suite-dynamic, │
│        my-tests, test/)                 │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ First Make Pass (Discovery)             │
├─────────────────────────────────────────┤
│ 1. Find test files (test/*.mk)          │
│ 2. Include test files                   │
│ 3. Discover test targets (test-*)       │
│ 4. Generate .generated/my-tests.mk      │
│    containing test execution rules      │
└──────────────┬──────────────────────────┘
               │
               ▼ Make detects new include
               ▼ and re-executes
┌─────────────────────────────────────────┐
│ Second Make Pass (Execution)            │
├─────────────────────────────────────────┤
│ 1. Include .generated/my-tests.mk       │
│ 2. All test rules now available         │
│ 3. Execute: make my-tests               │
│ 4. Tests run as normal targets          │
│    (no subprocess spawning)             │
└─────────────────────────────────────────┘
```

### Key Technique: Generated Rules

Instead of:
```makefile
# OLD: Recursive Make
@$(MAKE) test-foo >test-foo.log 2>&1
```

Generate and include:
```makefile
# NEW: Generated include file (.generated/my-tests.mk)
.PHONY: __test-wrapper/my-tests/test-foo
__test-wrapper/my-tests/test-foo:
	@$(MAKE) --no-print-directory test-foo \
		>$(WORKDIR)/.logs/test-foo.log 2>&1 && \
		echo "Passed: test-foo" || \
		(echo "Failed: test-foo" && exit 1)
```

Then in main Makefile:
```makefile
-include .generated/my-tests.mk

my-tests: $(foreach test,$(TESTS),__test-wrapper/my-tests/$(test))
```

## Benefits

### 1. Performance Improvement
- **Eliminates subprocess overhead** for test orchestration
- **Enables true parallelization**: `make -j8 my-tests` works naturally
- **Estimated speedup**: 10-30% for large test suites

### 2. Better Make Integration
- **Full dependency graph visible** to Make
- **Incremental execution** possible (though tests should run fresh)
- **Make's built-in parallelization** works without custom logic

### 3. Debugging
- **Generated rules are inspectable**: Look at `.generated/my-tests.mk`
- **Make's debug flags work**: `make -d my-tests` shows full graph
- **Simpler execution model**: No nested Make processes

## Challenges & Trade-offs

### 1. Test Isolation ⚠️

**Problem**: Variables leak between tests in same Make process.

```makefile
test-1:
	$(eval MY_VAR := foo)  # Sets variable
	
test-2:  # MY_VAR is still "foo" here!
	@echo $(MY_VAR)
```

**Current Solution**: Each test runs in subprocess → clean scope

**Dynamic Include Solution**: 
- Use target-specific variables where possible
- Document that tests must not pollute global scope
- Add linting to detect variable pollution

**Impact**: Requires test discipline, may break some existing tests.

### 2. Undefined Variable Detection

**Problem**: Can't run each test with `--warn-undefined-variables`

**Current Solution**: 
```makefile
$(MAKE) test-foo --warn-undefined-variables
```

**Dynamic Include Solution**:
- Run entire suite with `--warn-undefined-variables`
- First undefined variable fails the whole suite
- OR: Use wrapper that checks variables before test execution

**Impact**: Less precise error reporting, harder to isolate which test has undefined vars.

### 3. Output Capture Complexity

**Problem**: Still need to capture per-test output.

**Solution**: Same as current - shell redirection:
```makefile
@$(MAKE) test-foo >test-foo.log 2>&1
```

**But wait...** This still uses `$(MAKE)`!

**Real solution**: Direct execution with redirection:
```makefile
@(set -e; source test-foo-recipe) >test-foo.log 2>&1
```

**Impact**: More complex rule generation, need to extract recipe bodies.

### 4. Make Re-execution Overhead

**Problem**: Make re-executes on first run (when .mk file is generated).

**Impact**: 
- First run: 2 Make invocations (discovery + execution)
- Subsequent runs: 1 Make invocation (if .mk file is up-to-date)
- Net: Still faster than recursive Make per test

## Hybrid Approach: Best of Both Worlds

**Recommendation**: Use dynamic includes for **orchestration**, keep recursive Make for **test execution**.

```makefile
# Generated file has orchestration rules
.PHONY: run-all-tests
run-all-tests: test-wrapper-1 test-wrapper-2 test-wrapper-3

# But each wrapper still uses recursive Make for isolation
.PHONY: test-wrapper-1
test-wrapper-1:
	@$(MAKE) test-1 >test-1.log 2>&1  # Still isolated!
```

**Benefits**:
- ✅ Eliminates orchestration overhead (5 recursive calls → 0)
- ✅ Keeps test isolation (1 recursive call per test remains)
- ✅ Enables parallelization: `make -j8 run-all-tests`
- ✅ No changes to test semantics

**Performance**: ~20% faster (eliminates orchestration overhead, keeps test isolation)

## Implementation Roadmap

### Phase 1: Proof of Concept ✅ CURRENT
- [x] Create `bowerbird-suite-dynamic.mk`
- [x] Implement dynamic include generation
- [ ] Test with simple test suite
- [ ] Measure performance vs. current approach

### Phase 2: Hybrid Approach
- [ ] Keep recursive Make for test execution
- [ ] Use dynamic includes for orchestration
- [ ] Maintain backward compatibility

### Phase 3: Evaluation
- [ ] Run full test suite (255 tests)
- [ ] Measure performance improvement
- [ ] Identify any broken tests
- [ ] Document migration path

### Phase 4: Production (If Successful)
- [ ] Update all test suites
- [ ] Add configuration flag for old vs. new runner
- [ ] Update documentation
- [ ] Add to style guide

## Compatibility

### Make Version Requirements
- ✅ Make 3.81+: Auto re-execution supported
- ✅ Make 4.x: All features work

### Backward Compatibility
- Keep `bowerbird::test::suite` as-is
- Add `bowerbird::test::suite-dynamic` as opt-in
- Provide migration guide

## Performance Estimates

### Current Approach (255 tests)
```
Discovery:    ~0.5s  (find files, discover targets)
Orchestration: ~1.0s  (5 recursive Make calls)
Test Execution: ~12.75s (255 tests × ~50ms overhead)
Test Logic:    ~10.0s  (actual test work)
─────────────────────
Total:        ~24.25s
```

### Dynamic Include Approach (Hybrid)
```
Discovery:    ~0.5s  (find files, discover targets)
Generation:   ~0.3s  (generate .mk file)
Re-execution: ~0.2s  (Make re-exec overhead)
Orchestration: 0.0s  (no recursive calls!)
Test Execution: ~12.75s (still need isolation)
Test Logic:    ~10.0s  (actual test work)
─────────────────────
Total:        ~23.75s  (~2% faster)
```

### Dynamic Include Approach (No Isolation)
```
Discovery:    ~0.5s  (find files, discover targets)
Generation:   ~0.3s  (generate .mk file)
Re-execution: ~0.2s  (Make re-exec overhead)
Orchestration: 0.0s  (no recursive calls!)
Test Execution: 0.0s  (direct execution!)
Test Logic:    ~10.0s  (actual test work)
─────────────────────
Total:        ~11.0s  (~55% faster!)
```

**But**: Loses test isolation, may break tests.

## Recommendation

**Implement Hybrid Approach (Phase 2)**:
1. Use dynamic includes for orchestration (eliminates 5 calls per suite)
2. Keep recursive Make for test execution (maintains isolation)
3. Measure real-world performance improvement
4. If <10% improvement, stick with current approach (simpler is better)
5. If >20% improvement, make it the default

## Alternative: Just Optimize Current Approach

Before implementing dynamic includes, try:

### Option A: Reduce Orchestration Calls
```makefile
# Current: 5 sequential recursive Make calls
$1:
	@$(MAKE) list-tests/$1
	@$(MAKE) clean/$1
	@$(MAKE) run-primary/$1
	@$(MAKE) run-secondary/$1
	@$(MAKE) report/$1

# Better: Use proper dependencies
$1: list-tests/$1 clean/$1 run-tests/$1 report/$1

run-tests/$1: run-primary/$1 run-secondary/$1
```

**Speedup**: ~5% (eliminates 5 subprocess spawns per suite)

### Option B: Fast Mode Config
```makefile
bowerbird-test.config.fast-mode = 0  # default: thorough

ifeq ($(bowerbird-test.config.fast-mode),1)
  # Skip --debug=v for 30% speedup
  # Skip --warn-undefined-variables for 10% speedup
  MAKE_FLAGS =
else
  MAKE_FLAGS = --debug=v --warn-undefined-variables
endif
```

**Speedup**: ~40% in fast mode (but less thorough testing)

## Conclusion

The dynamic include approach is **technically feasible** but **high complexity** for **modest gains**.

**Recommended path**:
1. ✅ Create proof of concept (this branch)
2. ⏭️ Benchmark performance with real test suite
3. ⏭️ If <20% improvement, use simpler optimizations (Option A + B)
4. ⏭️ If >20% improvement AND maintains test isolation, proceed with hybrid approach

**Current status**: Proof of concept implemented, ready for testing.
