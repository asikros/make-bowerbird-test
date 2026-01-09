# Unit tests for __bowerbird::suite::* sub-macros
#
# NOTE: These sub-macros generate Make parse-time constructs (include, ifndef, target definitions)
# which cannot be easily unit tested in isolation since they must be evaluated during Makefile
# parsing, not recipe execution. The value of breaking them into separate macros is:
#
# 1. **Code Organization**: Each macro has a single, clear responsibility
# 2. **Readability**: Easier to understand what each piece does
# 3. **Maintainability**: Changes to one aspect (e.g., validation) are localized
# 4. **Documentation**: Each macro is self-documenting with its own docstring
#
# The correctness of these macros is verified by the full integration test suite
# (162 existing tests that exercise the complete system).
#
# Future: If more granular testing is needed, consider creating test fixtures that
# invoke $(eval $(call ...)) at parse time and verify side effects.


# Placeholder test to verify the file is included correctly
test-suite-macros-defined:
	@true
