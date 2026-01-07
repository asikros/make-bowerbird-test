# Mock Shell Testing Framework for Make Recipes

```
Status:   Draft
Project:  make-bowerbird-test
Created:  2026-01-07
Author:   Bowerbird Team
```

---

## Summary

This proposal introduces a **general-purpose mock shell framework** for the `make-bowerbird-test` repository that enables testing Make recipes without executing their commands. This allows unit testing of recipe logic, command construction, and control flow independently of the actual commands being invoked.

**Core Concept:**
Test the **recipe itself** (command construction, conditionals, variables) without relying on command execution or side effects.

**Key Features:**
- **Universal Command Tracing**: Works with any command, not just git
- **Environment Variable Activation**: Enabled via `BOWERBIRD_MOCK_SHELL` (not command-line flags)
- **Parallel Safe**: Each test uses target-specific log files
- **Recursive Make Pattern**: Outer test target invokes inner target with mock shell
- **Expected Output Comparison**: Uses `bowerbird::test::compare-files` to verify command sequences


## Problem

Testing Make recipes today requires executing the actual commands, which creates fundamental problems:

### Fundamental Issues

1. **Dependency on External Commands**: Tests require git, curl, wget, compiler toolchains, etc.
2. **Cannot Test Without Side Effects**: Commands modify filesystem, network, system state
3. **Slow Execution**: Network I/O, disk operations, compilation all take time
4. **Unreliable**: Network failures, permissions, missing tools cause flaky tests
5. **Limited Error Testing**: Hard to test error conditions without complex fixtures
6. **Recipe Logic vs Command Logic**: Testing recipe construction requires executing commands

### Examples

**We need to test recipe construction and logic independently of command execution.**

A recipe like:
```makefile
target:
	@echo "Building $@"
	$(CC) $(CFLAGS) -o $@ $<
	strip $@
```

Should be testable to verify:
- Variable expansion is correct
- Conditionals work as expected
- Commands are constructed properly
- Error handling logic executes correctly

**Without** requiring an actual C compiler, linker, or strip tool.

## Proposed Solution

Implement a **general-purpose command interception framework** that:
1. Captures shell commands without executing them
2. Simulates command success/failure based on patterns
3. Logs all commands for verification
4. Works with ANY command, not just specific tools

This allows testing the **recipe logic** separately from **command implementation**.

### Key Insight

**Any recipe that constructs commands from Make variables can be unit tested without executing those commands.**

## What Are We Actually Testing?

When using mock shell, we're testing the **Makefile logic**, not the **command behavior**:

### Testing Make's Job
- **Variable expansion**
```makefile
# Test that $(CFLAGS) expands correctly
$(CC) $(CFLAGS) -o $@ $<
# Expected: gcc -O2 -Wall -o program main.c
```

- **Conditional logic**
```makefile
# Test that flag is added when DEV_MODE is set
$(if $(DEV_MODE),--verbose)
# Expected with DEV_MODE: command --verbose
# Expected without: command
```

- **Target-specific variables**
```makefile
# Test that target-specific CFLAGS override global
target: CFLAGS += -DDEBUG
# Expected: gcc ... -DDEBUG ...
```

- **Foreach loops**
```makefile
# Test that foreach generates correct command sequence
$(foreach file,$(FILES),process $(file);)
# Expected: process a.txt; process b.txt; process c.txt;
```

- **String manipulation**
```makefile
# Test that substitution works correctly
$(patsubst %.c,%.o,$(SOURCES))
# Expected: main.o util.o helper.o
```

- **Override behavior**
```makefile
# Test that command-line overrides are applied
test-repo.branch=v2.0
# Expected: git clone ... --branch v2.0 ...
```

### NOT Testing Command Implementation
- Does git clone actually work?
- Does gcc produce valid binaries?
- Does curl handle redirects?
- Does docker authenticate correctly?

**Those are tested separately with integration tests that use real commands.**

### The Separation
```
┌─────────────────────────────────────────┐
│ Unit Tests (Mock Shell)                 │
│ • Test Makefile logic                   │
│ • Fast (no command execution)           │
│ • Many test cases                       │
│ • Test edge cases and errors            │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ Integration Tests (Real Commands)       │
│ • Test end-to-end functionality         │
│ • Slow (full execution)                 │
│ • Few smoke tests                       │
│ • Test actual behavior                  │
└─────────────────────────────────────────┘
```

This is the same principle as unit testing in programming:
- **Unit tests**: Test function logic with mocked dependencies
- **Integration tests**: Test with real dependencies

## Design

### 1. Environment Variable Activation

Use exported environment variables to enable mock mode, making it cleaner and more composable than command-line flags.

```makefile
# Mock shell script location
__BOWERBIRD_MOCK_SHELL_SCRIPT := $(WORKDIR_TEST)/.mock-shell.sh

# Generate mock shell script once
$(__BOWERBIRD_MOCK_SHELL_SCRIPT): | $(dir $(__BOWERBIRD_MOCK_SHELL_SCRIPT))/.
	$(file >$@,$(__BOWERBIRD_MOCK_SHELL_IMPL))
	@chmod +x "$@"

# If BOWERBIRD_MOCK_SHELL is set, use it as the shell
ifdef BOWERBIRD_MOCK_SHELL
    SHELL = $(BOWERBIRD_MOCK_SHELL)
    .SHELLFLAGS = -c
endif
```

### 2. Target-Specific Logs (Parallel Safe)

Each test uses its own log file specified via environment variable, enabling parallel test execution:

```makefile
test-mock-basic-clone: __MOCK_LOG = $(WORKDIR_TEST)/$@/.commands.log
test-mock-basic-clone: $(__BOWERBIRD_MOCK_SHELL_SCRIPT)
	@mkdir -p $(dir $(__MOCK_LOG))
	@>$(__MOCK_LOG)
	$(MAKE) BOWERBIRD_MOCK_SHELL=$(__BOWERBIRD_MOCK_SHELL_SCRIPT) \
	        BOWERBIRD_MOCK_LOG=$(__MOCK_LOG) \
	        TEST_MOCK_BASIC=true
	$(call bowerbird::test::compare-files,$(__MOCK_LOG),$@.expected)
```

### 3. Mock Shell Script

Generate a shell script that logs commands and simulates behavior. The script reads `BOWERBIRD_MOCK_LOG` environment variable for the target-specific log file:

```bash
#!/bin/sh
set -eu

# Log file from environment (set by test target)
LOG_FILE="${BOWERBIRD_MOCK_LOG:?BOWERBIRD_MOCK_LOG must be set}"

# Ensure log directory exists
mkdir -p "$(dirname "${LOG_FILE}")"

# Log the full command
echo "$@" >> "${LOG_FILE}"

# Simulate command execution based on patterns
case "$*" in
    *"git clone"*)
        # Extract path from git clone command (last argument)
        path=$(echo "$*" | sed -n 's/.* \([^ ]*\)$/\1/p')

        # Check for error conditions
        if echo "$*" | grep -q "nonexistent-branch"; then
            echo "fatal: Remote branch nonexistent-branch not found" >&2
            exit 128
        elif echo "$*" | grep -q "invalid.url"; then
            echo "fatal: repository not found" >&2
            exit 128
        elif [ -z "$path" ]; then
            echo "fatal: no path specified" >&2
            exit 1
        else
            # Simulate successful clone
            mkdir -p "$path/.git"
            echo "ref: refs/heads/main" > "$path/.git/HEAD"
            echo "[core]" > "$path/.git/config"
            touch "$path/bowerbird.mk"
            exit 0
        fi
        ;;
    *"rm -rfv"* | *"rm -rf"*)
        # Execute rm commands (needed for cleanup)
        eval "$@"
        exit $?
        ;;
    *"test -"*)
        # Execute test commands (needed for validation)
        eval "$@"
        exit $?
        ;;
    *"echo"* | *"printf"* | *"grep"* | *"mkdir"*)
        # Execute utility commands
        eval "$@"
        exit $?
        ;;
    *)
        # Default: log and succeed
        exit 0
        ;;
esac
```

### 4. Test Structure with Recursive Make

Tests use recursive make to invoke the actual dependency macro with mock shell, then compare logged commands against expected output:

```makefile
# test-mock-git-clone-basic
#
#	Tests basic git clone command construction without executing git.
#	Uses recursive make with mock shell and compares output to expected file.
#
#	Raises:
#		ERROR: If logged commands don't match expected output.
#
test-mock-git-clone-basic: __MOCK_LOG = $(WORKDIR_TEST)/$@/.commands.log
test-mock-git-clone-basic: $(__BOWERBIRD_MOCK_SHELL_SCRIPT)
	@mkdir -p $(dir $(__MOCK_LOG))
	@>$(__MOCK_LOG)
	$(MAKE) BOWERBIRD_MOCK_SHELL=$(__BOWERBIRD_MOCK_SHELL_SCRIPT) \
	        BOWERBIRD_MOCK_LOG=$(__MOCK_LOG) \
	        __TEST_MOCK_BASIC_TARGET=true \
	        __test-mock-basic-target
	$(call bowerbird::test::compare-files,$(__MOCK_LOG),$@.expected)

# Internal target invoked by recursive make
__test-mock-basic-target:
ifdef __TEST_MOCK_BASIC_TARGET
    $(call bowerbird::git-dependency, \
		name=test-repo, \
		path=$(WORKDIR_TEST)/test-mock-basic/deps/test-repo, \
		url=https://github.com/ic-designer/make-bowerbird-deps.git, \
		branch=main, \
		entry=bowerbird.mk)
endif
```

**Expected Output File** (`test-mock-git-clone-basic.expected`):
```
git clone --config advice.detachedHead=false --config http.lowSpeedLimit=1000 --config http.lowSpeedTime=60 --depth 1 --branch main https://github.com/ic-designer/make-bowerbird-deps.git $(WORKDIR_TEST)/test-mock-basic/deps/test-repo
test -n "$(WORKDIR_TEST)/test-mock-basic/deps/test-repo"
test -d "$(WORKDIR_TEST)/test-mock-basic/deps/test-repo/.git"
rm -rfv -- "$(WORKDIR_TEST)/test-mock-basic/deps/test-repo/.git"
test -d $(WORKDIR_TEST)/test-mock-basic/deps/test-repo
test -f $(WORKDIR_TEST)/test-mock-basic/deps/test-repo/bowerbird.mk
```

### 5. Test Categories

**Unit Tests (Mock Mode) - Recipe Logic:**
- Command construction with various parameters
- Variable expansion and substitution
- Conditional execution (`$(if)`, `ifdef`)
- Override application verification
- Flag generation based on conditions
- Error message formatting
- Path escaping and quoting
- Loop constructs (`$(foreach)`)
- Multi-line recipe handling

**Integration Tests (Real Commands):**
- One test per feature that executes real commands
- Verifies end-to-end functionality
- Ensures actual command behavior is correct
- Tests interaction with real system/tools

### 6. Expected Output Files

Each test has a corresponding `.expected` file containing the exact sequence of commands that should be logged. This approach:

- Provides clear documentation of expected behavior
- Makes test failures easy to diagnose (shows diff)
- Leverages existing `bowerbird::test::compare-files` functionality
- Supports version control for tracking behavior changes

**Example: Git Dependency** (`test-mock-git-clone-basic.expected`)
```
git clone --config advice.detachedHead=false --config http.lowSpeedLimit=1000 --config http.lowSpeedTime=60 --depth 1 --branch main https://github.com/ic-designer/make-bowerbird-deps.git $(WORKDIR_TEST)/test-mock-basic/deps/test-repo
test -n "$(WORKDIR_TEST)/test-mock-basic/deps/test-repo"
test -d "$(WORKDIR_TEST)/test-mock-basic/deps/test-repo/.git"
rm -rfv -- "$(WORKDIR_TEST)/test-mock-basic/deps/test-repo/.git"
```

**Example: Build Recipe** (`test-mock-compile.expected`)
```
gcc -Wall -Werror -O2 -c src/main.c -o build/main.o
gcc -Wall -Werror -O2 -c src/util.c -o build/util.o
gcc build/main.o build/util.o -o build/program
strip build/program
```

**Example: Download with Curl** (`test-mock-download.expected`)
```
mkdir -p downloads
curl --silent --show-error --fail -L -o downloads/package.tar.gz https://example.com/package.tar.gz
tar -xzf downloads/package.tar.gz -C build/
```

These examples show the mock shell works for **any command**, not just git.

## Example Test Cases

### Test 1: Basic Clone Command

**Makefile** (`test/bowerbird-deps/test-mock.mk`):
```makefile
test-mock-basic-clone: __MOCK_LOG = $(WORKDIR_TEST)/$@/.commands.log
test-mock-basic-clone: $(__BOWERBIRD_MOCK_SHELL_SCRIPT)
	@mkdir -p $(dir $(__MOCK_LOG))
	@>$(__MOCK_LOG)
	$(MAKE) BOWERBIRD_MOCK_SHELL=$(__BOWERBIRD_MOCK_SHELL_SCRIPT) \
	        BOWERBIRD_MOCK_LOG=$(__MOCK_LOG) \
	        __TEST_BASIC=true \
	        __test-basic-target
	$(call bowerbird::test::compare-files,$(__MOCK_LOG),$@.expected)

__test-basic-target:
ifdef __TEST_BASIC
    $(call bowerbird::git-dependency, \
		name=test-repo, \
		path=$(WORKDIR_TEST)/test-mock-basic/deps/test-repo, \
		url=https://github.com/ic-designer/make-bowerbird-deps.git, \
		branch=main, \
		entry=bowerbird.mk)
endif
```

**Expected** (`test/bowerbird-deps/test-mock-basic-clone.expected`):
```
git clone --config advice.detachedHead=false --config http.lowSpeedLimit=1000 --config http.lowSpeedTime=60 --depth 1 --branch main https://github.com/ic-designer/make-bowerbird-deps.git $(WORKDIR_TEST)/test-mock-basic/deps/test-repo
test -n "$(WORKDIR_TEST)/test-mock-basic/deps/test-repo"
test -d "$(WORKDIR_TEST)/test-mock-basic/deps/test-repo/.git"
rm -rfv -- "$(WORKDIR_TEST)/test-mock-basic/deps/test-repo/.git"
```

### Test 2: Branch vs Revision

**Makefile**:
```makefile
test-mock-revision: __MOCK_LOG = $(WORKDIR_TEST)/$@/.commands.log
test-mock-revision: $(__BOWERBIRD_MOCK_SHELL_SCRIPT)
	@mkdir -p $(dir $(__MOCK_LOG))
	@>$(__MOCK_LOG)
	$(MAKE) BOWERBIRD_MOCK_SHELL=$(__BOWERBIRD_MOCK_SHELL_SCRIPT) \
	        BOWERBIRD_MOCK_LOG=$(__MOCK_LOG) \
	        __TEST_REVISION=true \
	        __test-revision-target
	$(call bowerbird::test::compare-files,$(__MOCK_LOG),$@.expected)

__test-revision-target:
ifdef __TEST_REVISION
    $(call bowerbird::git-dependency, \
		name=test-repo, \
		path=$(WORKDIR_TEST)/test-mock-revision/deps/test-repo, \
		url=https://github.com/ic-designer/make-bowerbird-deps.git, \
		revision=abc123, \
		entry=bowerbird.mk)
endif
```

**Expected** (`test-mock-revision.expected`):
```
git clone --config advice.detachedHead=false --config http.lowSpeedLimit=1000 --config http.lowSpeedTime=60 --depth 1 --revision abc123 https://github.com/ic-designer/make-bowerbird-deps.git $(WORKDIR_TEST)/test-mock-revision/deps/test-repo
test -n "$(WORKDIR_TEST)/test-mock-revision/deps/test-repo"
test -d "$(WORKDIR_TEST)/test-mock-revision/deps/test-repo/.git"
rm -rfv -- "$(WORKDIR_TEST)/test-mock-revision/deps/test-repo/.git"
```

### Test 3: Dev Mode

Expected file shows NO `--depth 1` and NO `rm -rfv` commands:
```
git clone --config advice.detachedHead=false --config http.lowSpeedLimit=1000 --config http.lowSpeedTime=60 --branch main https://github.com/ic-designer/make-bowerbird-deps.git $(WORKDIR_TEST)/test-mock-dev/deps/test-repo
test -n "$(WORKDIR_TEST)/test-mock-dev/deps/test-repo"
test -d "$(WORKDIR_TEST)/test-mock-dev/deps/test-repo/.git"
```

### Test 4: Command-Line Overrides

Recursive make passes override through to inner invocation:
```makefile
test-mock-override: __MOCK_LOG = $(WORKDIR_TEST)/$@/.commands.log
test-mock-override: $(__BOWERBIRD_MOCK_SHELL_SCRIPT)
	@mkdir -p $(dir $(__MOCK_LOG))
	@>$(__MOCK_LOG)
	$(MAKE) BOWERBIRD_MOCK_SHELL=$(__BOWERBIRD_MOCK_SHELL_SCRIPT) \
	        BOWERBIRD_MOCK_LOG=$(__MOCK_LOG) \
	        test-repo.branch=v2.0 \
	        __TEST_OVERRIDE=true \
	        __test-override-target
	$(call bowerbird::test::compare-files,$(__MOCK_LOG),$@.expected)
```

Expected file shows overridden branch:
```
git clone ... --branch v2.0 ...
```

## Implementation Plan

1. **Phase 1: Framework Development** (make-bowerbird-test)
   - Create `src/bowerbird-test/bowerbird-mock-shell.mk`
   - Implement mock shell script generation (reads `BOWERBIRD_MOCK_LOG` env var)
   - Add support for `BOWERBIRD_MOCK_SHELL` environment variable
   - Create macros for test target setup
   - Implement helper functions for test execution
   - Add support for expected file comparison

2. **Phase 2: Framework Validation** (self-test)
   - Create `test/bowerbird-test/test-mock-framework.mk`
   - Test that mock shell is properly generated
   - Test that environment variables work correctly
   - Test that parallel execution is safe
   - Ensure framework self-hosts successfully

3. **Phase 3: Documentation and Examples**
   - Document framework usage in README
   - Create example test templates
   - Document patterns for common scenarios
   - Add quick start guide
   - Document integration with existing test runner

4. **Phase 4: Proof of Concept** (make-bowerbird-deps)
   - Apply framework to test git dependencies
   - Create `.expected` files for command sequences
   - Convert some existing tests to use mock shell
   - Measure performance improvements
   - Gather feedback and refine framework

5. **Phase 5: Ecosystem Adoption**
   - Roll out to other bowerbird-* repos
   - Create community examples
   - Integrate with CI/CD pipelines
   - Document best practices

## Benefits

### 1. Test Recipe Logic Without Command Dependencies

**Problem**: Testing a recipe that uses `git`, `curl`, `docker`, etc. requires those tools to be installed and working.

**Solution**: Mock shell logs commands without executing them.

**Example**:
```makefile
# This recipe can be tested without git installed
$(call bowerbird::git-dependency, name=foo, url=$(URL), branch=$(BRANCH), ...)

# Test verifies: URL construction, flag generation, error handling
# Without: Network access, git binary, remote repository
```

### 2. Fast Iteration (10-100x Faster)

**Before** (real commands):
```bash
make test-git-dependency  # 5-30 seconds (network, clone, cleanup)
```

**After** (mock shell):
```bash
make test-mock-git-dependency  # 0.1-0.5 seconds (log, compare)
```

**Impact**: Run tests after every change, not just before commit.

### 3. Test Error Conditions Easily

**Problem**: How do you test what happens when git clone fails with a 404?

**Before**: Create mock HTTP server, return 404, configure git to use it

**After**: Mock shell checks URL pattern, returns error:
```bash
case "$*" in
    *"invalid.url"*) echo "fatal: repository not found" >&2; exit 128 ;;
esac
```

### 4. Parallel Test Execution

**Before**: Tests modify shared filesystem, must run serially

**After**: Each test has its own log file, safe to run in parallel:
```bash
make -j8 test-mock-%  # All mock tests in parallel
```

### 5. Deterministic Behavior

**Before**: Tests fail randomly due to:
- Network timeouts
- Rate limiting
- Disk full
- Permission errors

**After**: Mock shell behavior is deterministic and controlled.

### 6. Clear Documentation

**Before**: Recipe does something, not clear what

**After**: Expected file shows exact command sequence:
```bash
git diff test/bowerbird-deps/test-mock-*.expected
# See exactly what changed in command construction
```

### 7. Test-Driven Development for Makefiles

```bash
# 1. Write expected output (what commands SHOULD run)
echo "gcc -O2 main.c -o program" > test-mock-build.expected

# 2. Write recipe (fails initially)
make test-mock-build  # FAIL: command mismatch

# 3. Fix recipe until test passes
make test-mock-build  # PASS

# 4. Verify with integration test
make test-integration-build  # Actually compiles
```

### 8. Portable Testing

Mock tests work:
- On developer machines (without tools installed)
- In minimal CI containers (no bloat)
- Offline (no network required)
- Cross-platform (no platform-specific tools needed)

## Migration Path

Existing tests continue to work as-is. New mock-based tests are separate test targets:

```bash
# Existing tests - still work, use real git
make check

# New mock tests - fast, no network
make test-mock-basic-clone
make test-mock-revision
make test-mock-dev-mode
make test-mock-override

# Run all mock tests in parallel
make -j test-mock-%

# Integration test - one real git clone per feature
make test-git-dependency-bowerbird-deps-success
```

Mock mode is **activated per-target** through environment variables, not globally:
```makefile
# Target uses mock shell for this invocation only
test-mock-example: __MOCK_LOG = $(WORKDIR_TEST)/$@/.commands.log
test-mock-example:
	$(MAKE) BOWERBIRD_MOCK_SHELL=$(MOCK_SHELL_SCRIPT) \
	        BOWERBIRD_MOCK_LOG=$(__MOCK_LOG) \
	        actual-target
```

## Testing the Test Framework

The mock testing framework itself should be validated:

### 1. Validation Tests

```makefile
# test-mock-framework-activation
#
#	Verifies that BOWERBIRD_MOCK_SHELL actually overrides SHELL.
#	Ensures mock shell script is created and made executable.
#
test-mock-framework-activation: $(__BOWERBIRD_MOCK_SHELL_SCRIPT)
	test -f $(__BOWERBIRD_MOCK_SHELL_SCRIPT)
	test -x $(__BOWERBIRD_MOCK_SHELL_SCRIPT)
	@echo "✓ Mock shell script created and executable"

# test-mock-log-isolation
#
#	Verifies that parallel tests use separate log files.
#	Ensures no race conditions when running with make -j.
#
test-mock-log-isolation:
	$(MAKE) -j test-mock-basic-clone test-mock-revision
	test -f $(WORKDIR_TEST)/test-mock-basic-clone/.commands.log
	test -f $(WORKDIR_TEST)/test-mock-revision/.commands.log
	@echo "✓ Log files are isolated per test"
```

### 2. Integration Validation

Keep at least one "real git" integration test per feature to ensure:
- Actual git commands work correctly
- Mock shell accurately simulates real behavior
- End-to-end functionality is preserved

```makefile
# test-integration-basic-clone
#
#	Integration test: Actually clones a real repository.
#	Ensures git commands work and mock behavior matches reality.
#
test-integration-basic-clone:
	test ! -d $(WORKDIR_TEST)/$@/deps || rm -rf $(WORKDIR_TEST)/$@/deps
	# This uses REAL git, no mock shell
	$(call bowerbird::git-dependency, \
		name=integration-test, \
		path=$(WORKDIR_TEST)/$@/deps/bowerbird-deps, \
		url=https://github.com/ic-designer/make-bowerbird-deps.git, \
		branch=main, \
		entry=bowerbird.mk)
	test -f $(WORKDIR_TEST)/$@/deps/bowerbird-deps/bowerbird.mk
	@echo "✓ Integration test passed"
```

### 3. Expected File Generation

Helper target to regenerate expected files when behavior changes intentionally:

```makefile
# update-mock-expected
#
#	Regenerates all .expected files from current behavior.
#	Use after intentional changes to command structure.
#	Review git diff before committing!
#
update-mock-expected:
	@echo "Regenerating expected files..."
	$(foreach test,basic-clone revision dev-mode override-branch override-url,\
		$(MAKE) test-mock-$(test) || true; \
		cp $(WORKDIR_TEST)/test-mock-$(test)/.commands.log \
		   test/bowerbird-deps/test-mock-$(test).expected; \
		echo "Updated test-mock-$(test).expected";)
	@echo "Review changes with: git diff test/bowerbird-deps/*.expected"
```

## Quick Reference

### Using the Framework (Consumer Repos)

**Step 1: Include the framework**
```makefile
# In your test file
include $(WORKDIR_DEPS)/bowerbird-test/src/bowerbird-test/bowerbird-mock-shell.mk
```

**Step 2: Create a mock test**
```makefile
# 1. Define test target with log file
test-mock-<feature>: __MOCK_LOG = $(WORKDIR_TEST)/$@/.commands.log
test-mock-<feature>: $(BOWERBIRD_MOCK_SHELL_SCRIPT)
	@mkdir -p $(dir $(__MOCK_LOG))
	@>$(__MOCK_LOG)
	# 2. Invoke via recursive make with mock shell
	$(MAKE) BOWERBIRD_MOCK_SHELL=$(BOWERBIRD_MOCK_SHELL_SCRIPT) \
	        BOWERBIRD_MOCK_LOG=$(__MOCK_LOG) \
	        __TEST_<FEATURE>=true \
	        __test-<feature>-target
	# 3. Compare with expected output
	$(call bowerbird::test::compare-files,$(__MOCK_LOG),$@.expected)

# 4. Define internal target with ifdef guard
__test-<feature>-target:
ifdef __TEST_<FEATURE>
    $(call your-macro-to-test, ...)
endif
```

**Step 3: Create expected output file**
```bash
# Run test once to generate log
make test-mock-<feature>

# Copy log to expected file
cp .make/test/.../test-mock-<feature>/.commands.log \
   test/<dir>/test-mock-<feature>.expected

# Review and commit
git add test/<dir>/test-mock-<feature>.expected
```

### Creating Expected Output File

```bash
# Run test once to generate log
make test-mock-<feature>

# Copy log to expected file
cp .make/test/*/test-mock-<feature>/.commands.log \
   test/bowerbird-deps/test-mock-<feature>.expected

# Review and commit
git add test/bowerbird-deps/test-mock-<feature>.expected
git diff --cached
```

### Key Files

**In make-bowerbird-test (Framework):**
- `src/bowerbird-test/bowerbird-mock-shell.mk` - Mock shell framework
- `$(WORKDIR_TEST)/.mock-shell.sh` - Generated mock shell script (not committed)
- `test/bowerbird-test/test-mock-framework.mk` - Framework validation tests

**In consumer repos (e.g., make-bowerbird-deps):**
- `test/*/test-mock-*.mk` - Mock tests using the framework
- `test/*/test-mock-*.expected` - Expected command outputs
- Consumer code adds `ifdef BOWERBIRD_MOCK_SHELL` support if needed

### Environment Variables

- `BOWERBIRD_MOCK_SHELL` - Path to mock shell script (activates mock mode)
- `BOWERBIRD_MOCK_LOG` - Path to target-specific log file (required by mock shell)

## Future Enhancements

### Phase 1: Framework Implementation (make-bowerbird-test)
1. **Core framework**: Implement mock shell generation in `make-bowerbird-test`
2. **Shell override**: Add `ifdef BOWERBIRD_MOCK_SHELL` support
3. **Test helpers**: Create utilities for test setup and comparison
4. **Documentation**: Document framework usage and patterns
5. **Examples**: Include example tests for common scenarios

### Phase 2: Validation (Proof of Concept)
6. **Apply to bowerbird-deps**: Use framework to test git dependencies
7. **Apply to bowerbird-test**: Self-host (test the test framework)
8. **Validate approach**: Ensure it works for real use cases
9. **Gather feedback**: Identify pain points and improvements
10. **Refine framework**: Make adjustments based on real usage

### Phase 3: Advanced Features
8. **Mock shell variants**: Support different simulation behaviors
   - Always succeed mode
   - Always fail mode
   - Slow execution simulation
   - Random failures for robustness testing
9. **Command recording mode**: Capture real command sequences to auto-generate expected files
10. **Fuzzing**: Generate random parameter combinations automatically
11. **Visual output**: Colored diff output when assertions fail
12. **Performance benchmarks**: Track test suite speed over time
13. **Pattern matching**: Support regex in expected files for variable parts
14. **Stateful simulation**: Mock shell remembers state across commands (e.g., files "created")

### Phase 4: Ecosystem Integration
15. **CI/CD integration**: Pre-built GitHub Actions, GitLab CI templates
16. **IDE support**: Generate expected files from editor
17. **Test generators**: Auto-generate tests from existing recipes
18. **Coverage reporting**: Track which recipes are tested vs untested

## Vision: Universal Make Testing

This framework represents a shift in how we test Makefiles:

### Current State
```
Write Makefile → Hope it works → Test by running it → Debug when it fails
```

Tests require:
- All external dependencies installed
- Network connectivity
- Filesystem access
- Slow, unreliable execution

### Future State with Mock Shell
```
Write Makefile → Test recipe logic → Integration test → Deploy with confidence
```

Tests verify:
- Command construction is correct
- Variables expand properly
- Conditionals work as expected
- Error handling is robust

**Without requiring any external dependencies.**

### Impact on Makefile Development

**Fast Feedback Loop:**
```bash
# Edit recipe
vim Makefile

# Test immediately (no compilation, no network, no tools needed)
make test-mock-recipe  # < 1 second

# Iterate quickly
```

**Confidence in Refactoring:**
```makefile
# Before: Afraid to change complex recipe
complicated-target:
	# 50 lines of bash with pipes, conditionals, loops
	# How do I test this without breaking things?

# After: Covered by unit tests
test-mock-complicated-target:
	# Verifies all command construction
	# Safe to refactor
```

**Better Collaboration:**
```bash
# Reviewer can see exactly what commands will execute
git diff test-mock-*.expected

# Clear documentation of behavior
# Version controlled command sequences
```

### The Big Picture

**Mock shell testing for Make is like:**
- Unit testing for code
- Mocking libraries for dependencies
- Type checking for correctness

It's a **fundamental testing primitive** that enables:
1. **Fast iteration**: Test without execution
2. **Reliable CI/CD**: No flaky tests
3. **Better design**: Forces clear command construction
4. **Easier debugging**: See exactly what would run
5. **Safe refactoring**: Tests verify behavior

### Long-term Goal

Make mock shell testing **the standard way** to test Makefile recipes, just like:
- `pytest` for Python
- `jest` for JavaScript
- `cargo test` for Rust

**Every complex Makefile recipe should have a corresponding mock test.**

## Design Decisions

### Why Environment Variables over Command-Line Flags?

**Chosen**: Environment variables (`BOWERBIRD_MOCK_SHELL`, `BOWERBIRD_MOCK_LOG`)

**Alternatives Considered**:
- Command-line flags (e.g., `--bowerbird-mock-commands`)
- Special targets (e.g., `.MOCK_MODE:`)
- Include file detection

**Rationale**:
- More composable with other tools
- Doesn't conflict with Make's argument parsing
- Cleaner activation per recursive make invocation
- No need for special flag handling logic
- Easier to integrate with external test runners

### Why Recursive Make Pattern?

**Chosen**: Outer test target invokes inner target via recursive make

**Alternatives Considered**:
- Direct macro invocation
- Include file switching
- Wrapper macros

**Rationale**:
- Clean separation of test setup and actual behavior
- Environment isolation (mock shell only for inner invocation)
- Supports `ifdef` guards naturally
- Matches existing test patterns in the codebase
- Easy to understand and debug

### Why Expected Output Files over Assertions?

**Chosen**: Version-controlled `.expected` files with `bowerbird::test::compare-files`

**Alternatives Considered**:
- Inline assertions (grep patterns)
- Custom assertion macros
- JSON/structured output

**Rationale**:
- Clear documentation of expected behavior
- Easy to review changes in version control
- Leverages existing `bowerbird::test::compare-files`
- Test failures show exact diff
- No custom assertion language needed

### Why Generate Mock Shell Script?

**Chosen**: Generate script from Make using `$(file)` function

**Alternatives Considered**:
- Check in static shell script
- Inline shell commands
- External script file

**Rationale**:
- Single source of truth (everything in Makefile)
- Can be customized per-project if needed
- No separate file to maintain
- Automatically kept in sync with tests
- Easier to extend with project-specific behavior

## Open Questions

### 1. Should mock shell script be generated or checked in?
**Answer**: Generate using `$(file)` function for maintainability and customization.

### 2. How to handle complex multi-line recipes?
**Answer**: Mock shell logs each command invocation separately. Multi-line recipes appear as separate lines in log, which matches shell execution behavior.

### 3. Should we support regex patterns in expected files?
**Answer**: No. Keep expected files as literal command sequences for clarity. If needed, can add separate "pattern" matcher later.

### 4. How to test interactive commands (if any)?
**Answer**: Not applicable for current use case. Git commands run non-interactively with `--config advice.detachedHead=false`.

### 5. Should mock mode be default for unit tests?
**Answer**: No. Keep explicit to avoid surprises. Tests opt-in by using recursive make with mock shell.

### 6. How to handle variable paths in expected files?
**Answer**: Expected files use actual WORKDIR_TEST paths. These are deterministic based on VERSION and project name. Could add variable substitution later if needed.

## Potential Issues and Mitigation

### Issue 1: Expected Files Out of Sync

**Problem**: Code changes modify command structure, causing test failures with confusing diffs.

**Mitigation**:
- Use `update-mock-expected` helper to regenerate files
- Review diffs carefully in version control
- Include expected files in code review
- Consider adding comments in expected files explaining unusual commands

### Issue 2: Mock Shell Doesn't Match Real Behavior

**Problem**: Mock shell simulates git incorrectly, tests pass but real execution fails.

**Mitigation**:
- Keep integration tests (real git) for critical paths
- Run both mock and integration tests in CI
- Update mock shell when git behavior changes
- Document mock shell limitations clearly

### Issue 3: Path Sensitivity in Expected Files

**Problem**: Tests fail in different environments due to path differences.

**Mitigation**:
- Use WORKDIR_TEST consistently (deterministic)
- Version detection might vary (VERSION=unknown)
- Consider making VERSION fixed in test environment
- Could add path normalization if needed

### Issue 4: Verbose Test Output

**Problem**: Mock tests generate large log files, hard to review failures.

**Mitigation**:
- Use `bowerbird::test::compare-files` for clean diff output
- Add summary line before/after test (✓ or ✗)
- Consider adding "first N lines that differ" output
- Clean up test artifacts after successful runs

### Issue 5: Mock Shell Becomes Complex

**Problem**: As more commands are mocked, shell script becomes hard to maintain.

**Mitigation**:
- Keep mock shell simple - focus on logging, not simulation
- Let utility commands (test, mkdir, echo) execute normally
- Move complex simulation to separate helper functions
- Consider splitting into multiple mock scripts by command type
- Document simulation behavior clearly

## Conclusion

Mock shell testing represents a **fundamental shift** in how we test Makefiles. By separating **recipe logic** (Make's responsibility) from **command implementation** (tool's responsibility), we enable:

1. **Fast, reliable unit tests** for Makefile recipes
2. **Independence from external tools and network**
3. **Easy testing of error conditions and edge cases**
4. **Parallel test execution for rapid feedback**
5. **Clear documentation through version-controlled expected files**

### Core Principle

> **Test the recipe, not the command.**

Just as we mock dependencies in unit tests for programming languages, we should mock commands in unit tests for Makefiles. This isn't about avoiding integration tests—it's about making unit tests **possible**.

### Path Forward

1. **Proof of Concept**: Implement in `make-bowerbird-deps` for git dependencies
2. **Validate**: Ensure approach works for real-world use cases
3. **Generalize**: Extract to `make-bowerbird-test` as a reusable framework
4. **Standardize**: Make this the recommended way to test complex Makefile recipes

This proposal provides the foundation for **treating Makefile testing as a first-class concern**, with the same rigor and tooling we apply to application code testing.

## Next Steps

### Immediate (Framework Development)
1. - Complete proposal document
2. ⏭️ Review and refine proposal with team
3. ⏭️ Implement basic mock shell script in `make-bowerbird-test`
4. ⏭️ Add `ifdef BOWERBIRD_MOCK_SHELL` support
5. ⏭️ Create example test templates
6. ⏭️ Write framework documentation

### Short-term (Proof of Concept)
7. ⏭️ Create example tests in `make-bowerbird-deps` using the framework
8. ⏭️ Test with git dependency scenarios
9. ⏭️ Measure performance improvements
10. ⏭️ Document learnings and pain points
11. ⏭️ Refine framework based on real usage

### Medium-term (Adoption)
12. ⏭️ Convert existing tests in bowerbird-* repos to use mock shell
13. ⏭️ Document patterns for different command types
14. ⏭️ Create example tests for common scenarios (git, curl, docker, build)
15. ⏭️ Publish blog post / tutorial

### Long-term (Ecosystem)
16. ⏭️ Make it standard practice across all bowerbird-* repos
17. ⏭️ Create community examples
18. ⏭️ Integrate with CI/CD pipelines
19. ⏭️ Develop IDE/editor integrations
20. ⏭️ Make it **the standard way** to test Makefiles
