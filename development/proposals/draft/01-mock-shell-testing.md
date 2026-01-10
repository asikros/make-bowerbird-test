# Mock Shell Testing Framework for Make Recipes

```
Status:   Draft (Revision 2) - Historical Reference
Project:  make-bowerbird-test
Created:  2026-01-07
Revised:  2026-01-08
Author:   Bowerbird Team
```

> **Note:** This proposal describes the design and evolution of the mock shell testing
> framework. The final implementation in `bowerbird-mock.mk` uses an inline shell string
> instead of an external script file to avoid macOS Gatekeeper quarantine issues.
> The core concepts and mechanisms described here remain accurate.

---

## Summary

This proposal introduces a **mock shell framework** for testing Make recipes without
executing their commands. It captures shell commands for verification, allowing unit
testing of recipe logic (variable expansion, conditionals, command construction)
independently of command behavior.

**Key Features:**
- **Target-Specific SHELL Override**: Uses `%: SHELL = ...` pattern to preserve
  `$(shell)` calls during parsing
- **Environment Variable Activation**: Enabled via `BOWERBIRD_MOCK_RESULTS`
- **Parallel Safe**: Each test uses target-specific results files
- **Recursive Make Pattern**: Outer test target invokes inner target with mock mode

**Benefits:**
- Fast, deterministic unit tests for Makefile recipes
- Test edge cases without external tool dependencies
- `$(shell)` calls during parsing work normally (not captured)


## Problem

Testing Make recipes today requires executing actual commands:

1. **Dependency on External Commands**: Tests require git, curl, compilers, etc.
2. **Cannot Test Without Side Effects**: Commands modify filesystem/network
3. **Slow Execution**: Network I/O, compilation take time
4. **Unreliable**: Network failures cause flaky tests
5. **Recipe Logic vs Command Logic**: Testing construction requires execution

**We need to test recipe construction independently of command execution.**


## Design

### Core Mechanism: Target-Specific SHELL

The key insight is using Make's **target-specific variables** with a pattern rule:

```makefile
# When BOWERBIRD_MOCK_RESULTS is set, override SHELL for all targets
ifdef BOWERBIRD_MOCK_RESULTS
%: SHELL = $(BOWERBIRD_MOCK_SHELL)
endif
```

**Why this works:**
- `$(shell ...)` calls happen at **parse time**, before any target builds
- Target-specific variables only affect **recipe execution**
- Therefore, `$(shell)` uses real shell; recipes use mock shell

**Comparison with command-line approach:**
```makefile
# OLD: Passes SHELL to nested make, affects $(shell) calls too
$(MAKE) SHELL=$(MOCK) target

# NEW: SHELL is inherited via pattern rule, $(shell) unaffected
$(MAKE) target
```

### Mock Shell Script

```makefile
define bowerbird-mock-shell-rendering
#!/bin/sh
# Extract command (always last argument after SHELLFLAGS)
eval "COMMAND=\"\$${$$#}\""
echo "$$COMMAND" >> "$${BOWERBIRD_MOCK_RESULTS:?BOWERBIRD_MOCK_RESULTS must be set}"
endef

BOWERBIRD_MOCK_SHELL := $(WORKDIR_TEST)/.mock-shell.sh
BOWERBIRD_MOCK_MK := $(lastword $(MAKEFILE_LIST))

$(BOWERBIRD_MOCK_SHELL): $(BOWERBIRD_MOCK_MK)
	@mkdir -p $(dir $@)
	$(file >$@,$(bowerbird-mock-shell-rendering))
	@chmod +x $@
```

The mock shell:
1. Receives all arguments: `$(SHELL) $(SHELLFLAGS) command`
2. Extracts the last argument (which is always the command)
3. Appends command to `BOWERBIRD_MOCK_RESULTS` file
4. Does NOT execute the command

**Note:** Using `$#` (last argument) ensures compatibility with any `.SHELLFLAGS`
configuration, whether it's `-c`, `-e -u -c`, or any other combination.

### Test Definition Macro

```makefile
define bowerbird::test::add-mock-test
.PHONY: $1
$1: export BOWERBIRD_MOCK_RESULTS = $$(WORKDIR_TEST)/$1/.results
$1: $$(BOWERBIRD_MOCK_SHELL)
	@mkdir -p $$(WORKDIR_TEST)/$1
	@rm -f $$(WORKDIR_TEST)/$1/.results
	$$(MAKE) $4 $2
	@diff -u <(printf '%s\n' $3) $$(WORKDIR_TEST)/$1/.results
endef
```

**Arguments:**
- `$1`: Test name (e.g., `test-mock-clean`)
- `$2`: Target to test (e.g., `clean`)
- `$3`: Expected output lines (quoted, newline-separated)
- `$4`: Optional extra make arguments

### Example Usage

```makefile
# Target under test
.PHONY: clean
clean:
	@rm -rf $(WORKDIR)/build
	@echo "Clean complete"

# Test definition
$(call bowerbird::test::add-mock-test,\
    test-mock-clean,\
    clean,\
    "rm -rf /path/to/build" "echo Clean complete",\
    )
```

---

## SHELLFLAGS Compatibility

### The Challenge

Make invokes the shell as: `$(SHELL) $(SHELLFLAGS) command`

The `.SHELLFLAGS` variable can be customized by users or projects:
- **Default:** `.SHELLFLAGS := -c` → `shell -c "command"`
- **Strict mode:** `.SHELLFLAGS := -e -u -c` → `shell -e -u -c "command"`
- **Debug mode:** `.SHELLFLAGS := -xc` → `shell -xc "command"`

A naive mock shell that assumes `$2` is the command will break with multi-flag
configurations:

```sh
# Broken approach
echo "$$2" >> "$BOWERBIRD_MOCK_RESULTS"

# shell -c "cmd"        → $2 = "cmd" ✓
# shell -e -u -c "cmd"  → $2 = "-u" ✗
```

### The Solution: Last-Argument Extraction

The command is **always the last argument**, regardless of flag configuration:

```sh
#!/bin/sh
# Extract command (always last argument after SHELLFLAGS)
eval "COMMAND=\"\$${$$#}\""
echo "$$COMMAND" >> "$${BOWERBIRD_MOCK_RESULTS:?BOWERBIRD_MOCK_RESULTS must be set}"
```

**How it works:**
- `$#` contains the total number of arguments
- `eval "\${$#}"` extracts the value of the last argument
- Works with any `.SHELLFLAGS` configuration

**Compatibility matrix:**

| .SHELLFLAGS | Invocation | Last Arg ($#) | Result |
|-------------|------------|---------------|--------|
| `-c` | `shell -c "cmd"` | `$2 = "cmd"` | ✓ |
| `-e -u -c` | `shell -e -u -c "cmd"` | `$4 = "cmd"` | ✓ |
| `-xc` | `shell -xc "cmd"` | `$2 = "cmd"` | ✓ |
| `-e -u -x -v -c` | `shell -e -u -x -v -c "cmd"` | `$6 = "cmd"` | ✓ |

### Testing SHELLFLAGS

The test suite includes comprehensive `.SHELLFLAGS` coverage:
- Default configuration (`-c`)
- Multiple separate flags (`-e -u -c`)
- Combined flags (`-xc`, `-euc`)
- Many flags (`-e -u -x -v -c`)
- Various flag combinations used in real projects

See [`test/bowerbird-test/test-mock-shellflags.mk`](../../test/bowerbird-test/test-mock-shellflags.mk)
for complete test coverage.

---

## Limitations

### Quote Handling is Fragile

**Problem:** Make strips some quotes before passing to shell. Single quotes in
expected output can break the comparison mechanism.

**Guidance:**
- Prefer double quotes in recipes where possible
- Accept that exact quote preservation is not guaranteed
- For complex quote scenarios, verify manually

**Example of fragility:**
```makefile
# Recipe:
target:
	@echo 'hello'

# May be captured as:
echo hello        # OR
echo 'hello'      # Depends on Make/shell version
```

### What Cannot Be Tested

1. **Command Output Dependencies**: `VAR=$(shell cmd)` in recipes
2. **Exit Code Logic**: `cmd || fallback` — all commands "succeed"
3. **Side Effect Dependencies**: Recipes checking for created files
4. **Shell Built-ins**: Loops, conditionals within single command

### Appropriate Use Cases

- Testing Make variable expansion in recipes
- Testing command construction and argument passing
- Testing conditional recipe generation
- Unit testing recipe logic without side effects

---

## Implementation Plan

### File Changes

1. **`src/bowerbird-test/bowerbird-mock.mk`** (simplify)
   - Remove parse-time `$(shell)` script creation
   - Add `ifdef BOWERBIRD_MOCK_RESULTS` pattern rule
   - Simplify test macro

2. **`src/bowerbird-test/bowerbird-compare.mk`** (no change)
   - Existing comparison macros work as-is

3. **`bowerbird.mk`** (no change)
   - Already includes mock module

### Testing Strategy

Focus tests on:
- Basic command capture (without quotes)
- Variable expansion verification
- Multiple commands in order
- Conditional target generation

Skip or simplify:
- Complex quote scenarios
- Special character edge cases

---

## Appendix: Issues from Previous Implementation

### Issue 1: $(shell) Contamination

**Symptom:** Results file contained parsing-time commands (`git describe`, etc.)

**Cause:** Passing `SHELL=...` on `$(MAKE)` command line affected `$(shell)` calls

**Solution:** Use target-specific `%: SHELL = ...` pattern rule

### Issue 2: Quote Corruption

**Symptom:** Expected file contained corrupted content like `echo single\nquotes`

**Cause:** Single quotes in expected output broke `printf '...'` command

**Solution:** Document as limitation; simplify expected output format

### Issue 3: Script Creation Race

**Symptom:** Mock shell script not found or permissions wrong

**Cause:** Complex parse-time script creation with `$(shell)`

**Solution:** Use simple recipe-based creation; depend on source file

### Issue 4: SHELLFLAGS Compatibility

**Symptom:** Mock shell breaks with non-default `.SHELLFLAGS` (e.g., `-e -u -c`)

**Cause:** Hardcoded `$2` assumes exactly one flag argument before command

**Original broken approach:**
```sh
echo "$$2" >> "$${BOWERBIRD_MOCK_RESULTS:?...}"
# Works with: shell -c "cmd"      (where $2 = "cmd")
# Breaks with: shell -e -u -c "cmd" (where $2 = "-u", $4 = "cmd")
```

**Solution:** Extract last argument using `$#`, which works with any flag configuration

```sh
eval "COMMAND=\"\$${$$#}\""
echo "$$COMMAND" >> "$${BOWERBIRD_MOCK_RESULTS:?...}"
# Works with: shell -c "cmd"        (last arg = "cmd")
# Works with: shell -e -u -c "cmd"  (last arg = "cmd")
# Works with: shell -xc "cmd"       (last arg = "cmd")
```

This approach is robust because Make always invokes: `$(SHELL) $(SHELLFLAGS) command`
The command is always the final argument, regardless of flag count or syntax.
