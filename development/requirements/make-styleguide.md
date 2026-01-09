# Make Style Guide

This document outlines the conventions and best practices for writing Makefiles in the Bowerbird project.

## Naming Conventions

### Constants
Use `UPPERCASE_WITH_UNDERSCORES` for constants:
```makefile
BOWERBIRD_COMMA := ,
WORKDIR_TEST := .make/test
```

### Namespaced Functions/Macros
Use `namespace::category::function-name` with kebab-case:
```makefile
bowerbird::test::compare-strings
bowerbird::test::find-test-files
```

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
Document all public macros with structured comments:
```makefile
# bowerbird::test::compare-strings,<str1>,<str2>
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
define bowerbird::test::compare-strings
    test "$1" = "$2" || \
            (echo "ERROR: Failed string comparison: '$1' != '$2'" >&2 && exit 1)
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
- Align continuation lines for readability:
```makefile
test-example:
	$(call bowerbird::test::compare-sets,\
		$(call find-files,path/to/search),\
		expected-file-1 expected-file-2 expected-file-3)
```
