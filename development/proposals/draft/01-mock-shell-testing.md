# Mock Shell Testing Framework for Make Recipes

```
Status:   Accepted
Project:  make-bowerbird-test
Created:  2026-01-07
Author:   Bowerbird Team
```

---

## Summary

This proposal introduces a **general-purpose mock shell framework** for the `make-bowerbird-test` repository that enables testing Make recipes without executing their commands. It captures shell commands for verification, allowing unit testing of recipe logic (variable expansion, conditionals, string manipulation, command construction) independently of command behavior (whether git/gcc/curl actually work).

**Key Features:**
- **Universal Command Tracing**: Works with any command, not just git
- **Environment Variable Activation**: Enabled via `BOWERBIRD_MOCK_RESULTS` environment variable
- **Parallel Safe**: Each test uses target-specific results files
- **Recursive Make Pattern**: Outer test target invokes inner target with mock shell
- **Expected Output Comparison**: Uses `bowerbird::test::compare-file-content` with inline expected output

**Benefits:**
- Fast, deterministic unit tests for Makefile recipes
- Test edge cases and error conditions easily
- No dependency on external tools or network access


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

## Design

### Examples

The mock shell framework supports testing three common patterns in Makefiles:

#### Example: Testing an Existing Target

Test a target that's already defined in your Makefile (e.g., a `clean` target):

```makefile
# Existing target in your Makefile
.PHONY: clean
clean:
	@rm -rf $(WORKDIR)/build
	@rm -rf $(WORKDIR)/dist
	@echo "Clean complete"

# Expected output for clean target
define mock-clean-expected
rm -rf $(WORKDIR)/build
rm -rf $(WORKDIR)/dist
echo Clean complete
endef

# Define the mock test
$(call bowerbird::test::add-mock-test,\
    test-mock-clean,\
    clean,\
    $(mock-clean-expected))
```

**What It Verifies:**
- `rm -rf $(WORKDIR)/build` is executed
- `rm -rf $(WORKDIR)/dist` is executed
- `echo Clean complete` is executed
- Commands run in correct order

**Note:** Expected output does NOT include `@` or `+` prefixes. Make strips these
before passing commands to the shell, so the mock shell receives commands without
these prefixes.

**Use Case:** Verify existing targets execute correct commands without side effects.

---

#### Example: Testing a Macro Called Within a Recipe

Test helper macros that are invoked during recipe execution:

```makefile
# Helper macro called within recipes (defined elsewhere)
define install-file
	@echo "Installing: $1 -> $2"
	@mkdir -p $(dir $2)
	@cp $1 $2
	@chmod 644 $2
endef

# Expected output for install-config target
define mock-install-config-expected
echo Installing: config/app.conf -> /etc/myapp/app.conf
mkdir -p /etc/myapp
cp config/app.conf /etc/myapp/app.conf
chmod 644 /etc/myapp/app.conf
endef

# Target definition for testing
mock-install-config:
	$(call install-file,config/app.conf,/etc/myapp/app.conf)

# Define the mock test
$(call bowerbird::test::add-mock-test,\
    test-mock-install-config,\
    mock-install-config,\
    $(mock-install-config-expected))
```

**What It Verifies:**
- Macro expands correctly in recipe context
- All file operations generated in correct order
- Correct paths and permissions in commands
- Multiple macro invocations work independently

**Use Case:** Test helper macros that perform file operations without modifying
filesystem.

---

#### Example: Testing a Macro That Generates Targets

Test macros that create targets dynamically (e.g., `bowerbird::git-dependency`):

```makefile
# Macro under test
define bowerbird::git-dependency
    $1/.:
		@git clone --depth 1 --branch $3 $2 $1
		@test -d $1/.git
endef

# Expected output
define mock-git-dependency-expected
git clone --depth 1 --branch main \
    https://github.com/example/repo.git /tmp/myrepo
test -d /tmp/myrepo/.git
endef

# Guarded macro call
ifdef __TEST_MOCK_GIT_DEPENDENCY
    $(call bowerbird::git-dependency,\
        $(WORKDIR_TEST)/test-mock-git-dependency/tmp/myrepo,\
        https://github.com/example/repo.git,\
        main)
endif

# Define the mock test
$(call bowerbird::test::add-mock-test,\
    test-mock-git-dependency,\
    $(WORKDIR_TEST)/test-mock-git-dependency/tmp/myrepo/.,\
    $(mock-git-dependency-expected),\
    __TEST_MOCK_GIT_DEPENDENCY=)
```

**What It Verifies:**
- Macro correctly generates target with proper prerequisites
- `git clone` command constructed with correct arguments
- `test -d` validation runs after clone

**Use Case:** Test macro-generated targets without executing git or creating files.

---

### How It Works

The framework provides these key components:

#### Mock Shell Script

```makefile
# Mock shell script rendering
define bowerbird-mock-shell-rendering
#!/bin/sh
set -eu

RESULTS_FILE="$${BOWERBIRD_MOCK_RESULTS:?BOWERBIRD_MOCK_RESULTS must be set}"
mkdir -p "$$(dirname "$${RESULTS_FILE}")"
echo "$$1" >> "$${RESULTS_FILE}"
endef

# Target to create the mock shell script
BOWERBIRD_MOCK_SHELL := $(WORKDIR_TEST)/.mock-shell.sh
__BOWERBIRD_MOCK_FILE := $(lastword $(MAKEFILE_LIST))

$(BOWERBIRD_MOCK_SHELL): $(__BOWERBIRD_MOCK_FILE)
	@mkdir -p $(dir $@)
	$(file >$@,$(bowerbird-mock-shell-rendering))
	@chmod +x "$@"
```

**Note:** The mock shell script depends on `$(__BOWERBIRD_MOCK_FILE)` (captured
via `$(MAKEFILE_LIST)`) to ensure it's regenerated if the script definition
changes.

#### Automatic SHELL Replacement

```makefile
# When BOWERBIRD_MOCK_RESULTS is set, replace SHELL with mock script
ifdef BOWERBIRD_MOCK_RESULTS
    SHELL := $(BOWERBIRD_MOCK_SHELL)
    .SHELLFLAGS :=
endif
```

#### Expected Output Format

Commands are logged exactly as the shell receives them, after Make processing:

**Make Processing Applied:**
- `@` prefix is stripped (suppresses echo)
- `+` prefix is stripped (forces execution even with `-n`)
- All Make variables are expanded
- Make functions are evaluated

**Shell Processing NOT Applied:**
- No shell interpretation occurs
- No command execution
- No exit codes captured
- No output redirection
- No pipes or command substitution

**Example Transformation:**

Recipe in Makefile:
```makefile
target:
	@echo "Building $(PROJECT)"
	@mkdir -p $(OUTDIR)
	$(CC) $(CFLAGS) -o $@ $<
```

Expected output (after Make processing, before shell execution):
```makefile
define expected
echo "Building myproject"
mkdir -p /tmp/output
gcc -Wall -O2 -o target source.c
endef
```

**Key Points:**
- Expected output matches commands as received by shell
- All variable expansion is complete
- No `@` or `+` prefixes
- Commands are logged in execution order

#### Comparison Helper

```makefile
# bowerbird::test::compare-file-content
#
#   Compares file contents against expected string value.
#
#   Args:
#       $1: Path to file containing actual output
#       $2: Expected string value
#
#   Errors:
#       Exits with non-zero code if file not found or content mismatch.
#
define bowerbird::test::compare-file-content
@test -f "$1" || (>&2 echo "ERROR: Results file not found: $1" && exit 1)
@$(call bowerbird::test::compare-strings,$(shell cat $1),$2)
endef
```

**Note:** Any command that returns a non-zero exit code will cause the test to
fail. This includes file checks, comparisons, and the mock shell script itself.

#### Test Definition Macro

```makefile
# bowerbird::test::add-mock-test-implementation
#
#   Internal implementation that generates the test target.
#
#   Args:
#       $1: Test name
#       $2: Target to test
#       $3: Expected output string
#       $4: Optional command-line variables (e.g., VAR1=value VAR2=value)
#
define bowerbird::test::add-mock-test-implementation
$1: __MOCK_RESULTS = $$(WORKDIR_TEST)/$1/.results
$1: $$(BOWERBIRD_MOCK_SHELL)
	$$(MAKE) BOWERBIRD_MOCK_RESULTS=$$(__MOCK_RESULTS) $4 $2
	$$(call bowerbird::test::compare-file-content,$$(__MOCK_RESULTS),$3)
endef

# bowerbird::test::add-mock-test
#
#   Adds a mock test target with automatic boilerplate.
#
#   Args:
#       $1: Test name
#       $2: Target to test
#       $3: Expected output string
#       $4: Optional command-line variables (e.g., VAR1=value VAR2=value)
#
#   Example:
#       $(call bowerbird::test::add-mock-test,\
#           test-mock-clean,clean,$(mock-clean-expected))
#       $(call bowerbird::test::add-mock-test,\
#           test-mock-git-dep,myrepo/.,$(expected),\
#           __TEST_MOCK_GIT_DEPENDENCY=)
#
define bowerbird::test::add-mock-test
$(eval $(call bowerbird::test::add-mock-test-implementation,$1,$2,$3,$4))
endef
```

**The Mechanism:**
1. User calls `bowerbird::test::add-mock-test` with test name, target, and
   expected output
2. Macro generates test target (using exact name provided) that depends on
   `$(BOWERBIRD_MOCK_SHELL)`
3. Test invokes recursive `$(MAKE)` with `BOWERBIRD_MOCK_RESULTS` environment
   variable
4. Framework detects `BOWERBIRD_MOCK_RESULTS` and replaces `SHELL`, clears
   `.SHELLFLAGS`
5. All recipe commands execute through mock shell (command passed as `$1`)
6. Mock shell logs commands to results file
7. Test uses `compare-file-content` to verify results against expected output

---

### Test Discovery

The test discovery mechanism in `bowerbird::test::find-test-targets` must be
updated to recognize both explicit target definitions and macro-generated
tests.

**Current Implementation:**
```makefile
# bowerbird::test::find-test-targets
#
#   Discovers tests by finding targets matching the pattern (default: test*)
#
define bowerbird::test::find-test-targets
$(sort $(shell sed -n \
    's/\(^$(subst *,[^:]*,$(BOWERBIRD_TEST/CONFIG/TARGET_PATTERN_USER))\):.*/\1/p' \
    $1 2>/dev/null))
endef
```

This works for explicit targets:
```makefile
test-foo:
    recipe...
```

**Proposed Enhancement:**
```makefile
# bowerbird::test::find-test-targets
#
#   Discovers tests from both explicit targets and add-mock-test calls.
#   Handles line continuation (backslash) for multi-line macro calls.
#
define bowerbird::test::find-test-targets
$(sort $(shell cat $1 | \
    sed ':a;/\\$$/N;s/\\\n[ \t]*//;ta' | \
    sed -n \
        -e 's/\(^$(subst *,[^:]*,$(BOWERBIRD_TEST/CONFIG/TARGET_PATTERN_USER))\):.*/\1/p' \
        -e 's/.*bowerbird::test::add-mock-test,[ \t]*\([^,]*\).*/\1/p' \
    2>/dev/null))
endef
```

**What It Does:**
1. **First sed**: Joins continuation lines into single lines
   - `:a` - Label for loop
   - `/\\$$/N` - If line ends with backslash, read next line
   - `s/\\\n[ \t]*//` - Remove backslash, newline, and leading whitespace
   - `ta` - Jump back to label `:a` to continue joining
2. **Second sed, first pattern**: Matches explicit target definitions
   - `^$(BOWERBIRD_TEST/CONFIG/TARGET_PATTERN_USER):` - Target at line start
   - Extracts target name before the colon
3. **Second sed, second pattern**: Matches add-mock-test macro calls
   - `bowerbird::test::add-mock-test,` - Finds macro invocation
   - `[ \t]*\([^,]*\)` - Captures first argument (test name)
   - Handles optional whitespace after comma
4. **sort**: Sorts and deduplicates all discovered tests

**Handles Both Formats:**
```makefile
# Single-line macro call
$(call bowerbird::test::add-mock-test,test-foo,target,$(expected))

# Multi-line macro call with backslash continuation
$(call bowerbird::test::add-mock-test,\
    test-bar,\
    target,\
    $(expected))
```

**Example Discovery:**

Given a test file:
```makefile
# Explicit target
test-explicit-clean:
    @rm -rf build

# Macro-generated test
$(call bowerbird::test::add-mock-test,\
    test-mock-clean,\
    clean,\
    $(expected))
```

The updated discovery mechanism finds both:
- `test-explicit-clean` (from explicit target definition)
- `test-mock-clean` (from macro call)

---

## Implementation Plan

### File Structure

1. **`src/bowerbird-test/bowerbird-mock.mk`** (new file)
   - Mock shell script generation (`BOWERBIRD_MOCK_SHELL` target)
   - Mock shell script rendering (`bowerbird-mock-shell-rendering` define)
   - Automatic SHELL replacement (ifdef `BOWERBIRD_MOCK_RESULTS`)
   - Test definition macro (`bowerbird::test::add-mock-test`)

2. **`src/bowerbird-test/bowerbird-compare.mk`** (update existing)
   - Add `bowerbird::test::compare-file-content` macro

3. **`src/bowerbird-test/bowerbird-test-runner.mk`** (update existing)
   - Enhance `bowerbird::test::find-test-targets` for mock test discovery

4. **`bowerbird.mk`** (update existing)
   - Include `src/bowerbird-test/bowerbird-mock.mk`

### Integration

Mock testing is automatically available once `bowerbird.mk` is included. Tests
activate mock mode by:
1. Defining test using `bowerbird::test::add-mock-test` macro, OR
2. Setting `BOWERBIRD_MOCK_RESULTS` environment variable in recursive make

No additional configuration required.

### Backwards Compatibility

**Breaking Changes:**
- Test discovery patterns change slightly (adds macro call detection)
- Existing tests that manually set `SHELL` may conflict with mock framework

### Testing

Add comprehensive tests in `test/bowerbird-test/`:
- `test-mock-basic.mk` - Basic mock shell functionality
- `test-mock-discovery.mk` - Test discovery with macro calls
- `test-mock-multiline.mk` - Multi-line macro call discovery
- `test-compare-file-content.mk` - File content comparison

### Documentation

Update `README.md` with:
- Mock testing overview
- Usage examples
- API documentation for new macros

---

## Limitations

The mock shell framework has inherent limitations due to its design:

### What It Cannot Test

1. **Command Output Dependencies**
   - Cannot test recipes that use command substitution: `VAR=$(shell cmd)`
   - Cannot test recipes that use pipes: `cmd1 | cmd2`
   - Cannot test recipes that redirect output: `cmd > file`

2. **Exit Code Logic**
   - Cannot test recipes with conditional logic based on exit codes
   - All mocked commands implicitly succeed (exit 0)
   - The mock shell only logs commands, never executes them
   - No actual exit codes from commands are captured
   - Cannot test error handling paths: `cmd || fallback`

3. **Side Effect Dependencies**
   - Cannot test recipes that depend on files created by commands
   - Cannot test recipes that check for command-created state
   - File checks like `test -f output.txt` are logged but not executed
   - The mock shell cannot verify actual file existence

4. **Shell Built-ins and Complex Logic**
   - Shell loops, conditionals, and functions are not executed
   - Complex shell scripts in recipes may not work correctly

### Appropriate Use Cases

Mock testing is ideal for:
- Testing Make variable expansion in recipes
- Testing command construction and argument passing
- Testing conditional recipe generation
- Testing macro-generated targets
- Unit testing recipe logic without side effects

For testing actual command behavior, integration tests, or end-to-end
workflows, use traditional tests that execute real commands.

### Cleanup and Results Management

- Mock results files (`.results`) are overwritten on each test run
- Tests are `.PHONY` targets and always execute when invoked
- Users are responsible for cleaning test artifacts
- Mock results are suitable for temporary test validation only

### Mock Shell Script Dependency

The mock shell script (`BOWERBIRD_MOCK_SHELL`) must be generated before any
mock tests run. The `bowerbird::test::add-mock-test` macro automatically
creates this dependency, but manual test invocation must ensure
`$(BOWERBIRD_MOCK_SHELL)` exists.
