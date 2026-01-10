# Make Style Guide

This document outlines the conventions and best practices for writing Makefiles in the Bowerbird project.

## Naming Conventions

### Constants
Use `family::library::UPPERCASE` pattern with `define` for framework constants:
```makefile
define bowerbird::test::COMMA
,
endef

define bowerbird::test::NEWLINE
(newline characters)
endef

WORKDIR_TEST := .make/test
```

### Variables

**Public Variables (user-configurable or frequently referenced):**
Use dot-notation with lowercase and hyphens:
```makefile
bowerbird-test.config.fail-exit-code := 0
bowerbird-test.constant.ext-pass := pass
bowerbird-test.system.makepid := $(shell echo $$PPID)
```

**Internal Variables (framework-internal state):**
Use slash-notation with uppercase:
```makefile
BOWERBIRD_TEST/FILES/my-suite := $(wildcard ...)
BOWERBIRD_TEST/TARGETS/my-suite := test-a test-b
BOWERBIRD_TEST/CACHE/TESTS_PREV_FAILED/my-suite := test-c
```

This distinction makes it clear which variables are part of the public API.

### Namespaced Functions/Macros

Use `family::library::verb-noun` pattern with kebab-case:
- **family**: Project family (e.g., `bowerbird`)
- **library**: Component/library (e.g., `test`, `git`, `help`)
- **verb-noun**: Action in imperative form (e.g., `compare-strings`, `find-files`, `add-mock-test`)

**Public macros:**
```makefile
bowerbird::test::compare-strings
bowerbird::test::find-test-files
bowerbird::test::suite
bowerbird::test::add-mock-test
```

**Private macros** (prefixed with `__`):
```makefile
bowerbird::test::__suite-impl
bowerbird::test::__validate-args
bowerbird::test::__discover-files
bowerbird::test::__generate-runner-targets
```

The imperative verb-noun form makes it clear what action the macro performs.

### File, Macro, and Test Naming Consistency

Maintain consistent naming across related files, primary macros, and test files:

**Pattern:**
- Source file: `bowerbird-<component>.mk`
- Primary macro: `bowerbird::test::<component>` or `bowerbird::<component>`
- Test file: `test-<component>.mk`

**Examples:**
| Source File | Primary Macro | Test File |
|------------|---------------|-----------|
| `bowerbird-suite.mk` | `bowerbird::test::suite` | `test-suite.mk` |
| `bowerbird-compare.mk` | `bowerbird::test::compare-*` | `test-compare-*.mk` |
| `bowerbird-mock.mk` | `bowerbird::test::add-mock-test` | `test-mock.mk` |

This consistency makes the codebase more navigable and predictable.

### Targets
- **Test targets**: Use `test-` prefix with descriptive kebab-case names
  ```makefile
  test-compare-strings-equal
  test-mock-shell-script-exists
  ```
- **Internal targets**: Use `_` or `__` prefix to indicate private/helper targets
  ```makefile
  __test-mock-error-internal
  _test-underscore-prefix
  ```

## Documentation

### Macro/Function Docstrings

Document all public macros with structured comments. Use simple comma-separated argument names in the header, and add inline parameter comments after the `define` statement:

```makefile
# bowerbird::test::compare-strings, str1, str2
#
#   Brief description of what the function does.
#
#   Args:
#       str1: Description of first argument.
#       str2: Description of second argument.
#
#   Errors:
#       Description of error conditions and behavior.
#
#   Example:
#       $(call bowerbird::test::compare-strings,equal,equal)
#       ! $(call bowerbird::test::compare-strings,not-equal,different)
#
define bowerbird::test::compare-strings # str1, str2
    test "$1" = "$2" || \
            (echo "ERROR: Failed string comparison: '$1' != '$2'" >&2 && exit 1)
endef
```

**Format Rules:**
- Header: `# macro-name, arg1, arg2` (simple comma-separated, no angle brackets)
- Inline comment: `define macro-name # arg1, arg2` (matches header args)
- Use consistent arg names between header and inline comment

**Inline Parameter Comments:**
- Add `# arg1, arg2, ...` after `define` to document what `$1`, `$2`, etc. represent
- Use `# (no args)` for macros that take no parameters
- This makes the macro body more readable by clarifying positional arguments

```makefile
# Good - parameters clearly documented
define bowerbird::test::__validate-args # target, path
$$(if $1,,$$(error ERROR: missing target))
$$(if $2,,$$(error ERROR: missing path))
endef

# Good - no parameters clearly indicated
define bowerbird::test::__reset-config # (no args)
bowerbird-test.config.file-pattern-user := $$(bowerbird-test.config.file-pattern-default)
endef

# Bad - unclear what $1, $2, $3 represent
define bowerbird::test::__discover-files
export BOWERBIRD_TEST/FILES/$1 := $$(call bowerbird::test::find-test-files,$2,$3)
endef
```

### Test Targets
Test targets should have descriptive names that explain what they test. **No docstrings needed for test targets:**
```makefile
# Good - descriptive name
test-compare-strings-equal:
	$(call bowerbird::test::compare-strings,alpha,alpha)


# Bad - vague name requiring docstring
test-strings:
	$(call bowerbird::test::compare-strings,alpha,alpha)
```

## File Operations

### Blanking vs. Removing Files

**Prefer blanking files over removing them when they will be immediately recreated:**

```makefile
# Good - blank the file (faster, avoids unnecessary syscalls)
test-target:
	@: > $(WORKDIR_TEST)/results.txt
	$(MAKE) target-that-appends-to-results

# Bad - remove then recreate (unnecessary file deletion)
test-target:
	@rm -f $(WORKDIR_TEST)/results.txt
	$(MAKE) target-that-appends-to-results
```

**Rationale:**
- `: > file` truncates the file to zero bytes (blanking it)
- This is faster than `rm -f` followed by recreation
- Avoids race conditions if other processes are watching the file
- Preserves file permissions and inode
- Use `rm -rf` only for actual cleanup targets (e.g., `clean`, `distclean`)

**Examples:**
```makefile
# Blanking a mock results file before running tests
@: > $(WORKDIR_TEST)/mock/.results
$(MAKE) BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/mock/.results test-target

# Blanking a log file before a new run
@: > $(WORKDIR_TEST)/test.log
```

## Spacing and Formatting

### Vertical Spacing
- **Two blank lines** between logically related but distinct targets or macro definitions
- **One blank line** within tightly coupled groups (e.g., target and its prerequisites)
- **No blank lines** within a target's recipe or within a macro definition

```makefile
test-compare-strings-equal:
	$(call bowerbird::test::compare-strings,alpha,alpha)


test-compare-strings-not-equal:
	! $(call bowerbird::test::compare-strings,alpha,beta)


test-compare-strings-case-sensitive:
	! $(call bowerbird::test::compare-strings,Alpha,alpha)
```

### Indentation
- Use **tabs** for recipe lines (Make requirement)
- Use **tabs** for indentation within `define` blocks
- Use **tabs** for continuation lines in multi-line function calls:
```makefile
# Good - continuation lines indented with tabs
$(call bowerbird::test::add-mock-test,\
	test-mock-basic,\
	mock-test-target,\
	mock-expected-output,)

# Good - multi-line call in recipe also uses tabs
test-example:
	$(call bowerbird::test::compare-sets,\
		$(call find-files,path/to/search),\
		expected-file-1 expected-file-2 expected-file-3)

# Bad - no indentation on continuation lines
$(call bowerbird::test::add-mock-test,\
test-mock-basic,\
mock-test-target,\
mock-expected-output,)
```
