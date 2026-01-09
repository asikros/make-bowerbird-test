# Experimental: Dynamic Include-Based Test Runner
#
# This approach eliminates recursive Make by generating include files on-the-fly.
# Make will automatically re-execute when included files are generated/updated.
#
# Key Insight: Use Make's automatic re-execution feature:
#   1. First pass: Generate .mk file with test rules
#   2. Make detects new include file and re-executes
#   3. Second pass: Run tests using generated rules

WORKDIR_TEST ?= $(error ERROR: Undefined variable WORKDIR_TEST)

bowerbird-test-dynamic.config.fail-exit-code = 0
bowerbird-test-dynamic.config.suppress-warnings = 0

bowerbird-test-dynamic.constant.generated-dir = $(WORKDIR_TEST)/.generated
bowerbird-test-dynamic.constant.ext-fail = fail
bowerbird-test-dynamic.constant.ext-log = log
bowerbird-test-dynamic.constant.ext-pass = pass


# bowerbird::test::suite-dynamic,<target>,<path>
#
#   Experimental version that uses dynamic include files instead of recursive Make.
#
#   Generates a .mk file containing all test execution rules, then includes it.
#   Make automatically re-executes when the include file is created.
#
#   Benefits:
#   - No recursive Make for orchestration
#   - Faster (no subprocess spawning overhead)
#   - Full dependency graph visible to Make
#
#   Challenges:
#   - Test isolation requires careful variable scoping
#   - Output capture needs alternative mechanism
#   - Undefined variable detection per test is harder
#
define bowerbird::test::suite-dynamic # target, path
$(eval $(call __bowerbird::test::suite-dynamic-impl,$1,$2))
endef


# Generate the include file path for this suite
define __bowerbird::test::suite-dynamic-generated-file # suite-name
$(bowerbird-test-dynamic.constant.generated-dir)/$1.mk
endef


# Main implementation - generates the include file and loads it
define __bowerbird::test::suite-dynamic-impl # target, path
# Validation
$$(if $1,,$$(error ERROR: missing target in suite-dynamic))
$$(if $2,,$$(error ERROR: missing path in suite-dynamic))

# Define the generated file path
BOWERBIRD_DYNAMIC_GENERATED/$1 := $$(call __bowerbird::test::suite-dynamic-generated-file,$1)

# Discover test files
ifndef BOWERBIRD_TEST/FILES/$1
export BOWERBIRD_TEST/FILES/$1 := $$(shell test -d $2 && find $$(abspath $2) -type f -name 'test*.mk' 2>/dev/null)
$$(if $$(BOWERBIRD_TEST/FILES/$1),,$$(if $$(filter 0,$$(bowerbird-test-dynamic.config.suppress-warnings)),$$(warning WARNING: No test files found in '$2')))
endif

# Include test files to get targets
ifneq (,$$(BOWERBIRD_TEST/FILES/$1))
ifeq ($$(filter $$(MAKEFILE_LIST),$$(BOWERBIRD_TEST/FILES/$1)),)
include $$(BOWERBIRD_TEST/FILES/$1)
endif
endif

# Discover test targets (only if we have files)
ifndef BOWERBIRD_TEST/TARGETS/$1
ifneq (,$$(BOWERBIRD_TEST/FILES/$1))
BOWERBIRD_TEST/TARGETS/$1 := $$(sort $$(shell cat $$(BOWERBIRD_TEST/FILES/$1) | \
    sed -e ':a' -e '/\\$$$$/N' -e 's/\\\n//g' -e 'ta' | \
    sed -n -e 's/\(^test[^:]*\):.*/\1/p' 2>/dev/null))
endif
endif

# Generate the include file (this is the key innovation)
# The file contains all test execution rules without using recursive Make
$$(BOWERBIRD_DYNAMIC_GENERATED/$1): $$(BOWERBIRD_TEST/FILES/$1)
	@mkdir -p $$(dir $$@)
	@echo "# Auto-generated test execution rules for suite: $1" > $$@
	@echo "# Generated at: $$(shell date)" >> $$@
	@echo "" >> $$@
	$$(call __bowerbird::test::suite-dynamic-generate-rules,$$@,$1)

# Include the generated file (Make will re-execute if it doesn't exist or is outdated)
-include $$(BOWERBIRD_DYNAMIC_GENERATED/$1)

# Main suite target depends on all test wrapper targets
.PHONY: $1
$1: $$(foreach test,$$(BOWERBIRD_TEST/TARGETS/$1),__test-wrapper/$1/$$(test))
	@echo ""
	@echo "Suite complete: $1"
	@echo "Tests run: $$(words $$(BOWERBIRD_TEST/TARGETS/$1))"

endef


# Generate the test execution rules and write to file
# This replaces the recursive $(MAKE) calls with direct target execution
define __bowerbird::test::suite-dynamic-generate-rules # output-file, suite-name
	@echo "# Test wrapper targets for suite: $2" >> $1
	@echo "" >> $1
	@for test in $(BOWERBIRD_TEST/TARGETS/$2); do \
		echo ".PHONY: __test-wrapper/$2/$$test" >> $1; \
		echo "__test-wrapper/$2/$$test:" >> $1; \
		echo "	@echo 'Running: $$test'" >> $1; \
		echo "	@mkdir -p \$$(dir $(WORKDIR_TEST)/.logs/$2/$$test.log)" >> $1; \
		echo "	@mkdir -p \$$(dir $(WORKDIR_TEST)/.results/$2/$$test.pass)" >> $1; \
		echo "	@( \\" >> $1; \
		echo "		\$$(MAKE) --no-print-directory $$test \\" >> $1; \
		echo "			>$(WORKDIR_TEST)/.logs/$2/$$test.log 2>&1 && \\" >> $1; \
		echo "		( \\" >> $1; \
		echo "			echo 'Passed: $$test' && \\" >> $1; \
		echo "			echo 'Passed: $$test' > $(WORKDIR_TEST)/.results/$2/$$test.pass \\" >> $1; \
		echo "		) \\" >> $1; \
		echo "	) || ( \\" >> $1; \
		echo "		echo 'Failed: $$test' && \\" >> $1; \
		echo "		echo 'Failed: $$test' > $(WORKDIR_TEST)/.results/$2/$$test.fail && \\" >> $1; \
		echo "		cat $(WORKDIR_TEST)/.logs/$2/$$test.log >&2 && \\" >> $1; \
		echo "		exit $(bowerbird-test-dynamic.config.fail-exit-code) \\" >> $1; \
		echo "	)" >> $1; \
		echo "" >> $1; \
	done
endef
