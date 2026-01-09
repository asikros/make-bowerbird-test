# Example: Dynamic Include Test Runner
#
# This demonstrates the dynamic include approach without recursive Make.
# Run with: make -f example-dynamic-include.mk demo-suite

WORKDIR_TEST := .make/test-dynamic

# Include the experimental dynamic runner
include src/bowerbird-test/bowerbird-constants.mk
include src/bowerbird-test/bowerbird-compare.mk
include src/bowerbird-test/bowerbird-find.mk
include src/bowerbird-test/bowerbird-suite-dynamic.mk

# Create a test suite using dynamic includes
$(call bowerbird::test::suite-dynamic,demo-suite,test/bowerbird-test)

# For comparison, also show what files get generated
.PHONY: show-generated
show-generated:
	@echo "Generated include file:"
	@echo "======================"
	@cat $(WORKDIR_TEST)/.generated/demo-suite.mk 2>/dev/null || echo "Not yet generated (run make demo-suite first)"
	@echo ""
	@echo "To generate without running:"
	@echo "  make $(WORKDIR_TEST)/.generated/demo-suite.mk"

.PHONY: clean-generated
clean-generated:
	rm -rf $(WORKDIR_TEST)/.generated

# Show the difference in execution
.PHONY: compare-approaches
compare-approaches:
	@echo "Current approach (recursive Make):"
	@echo "  Each test: \$$(MAKE) test-name >log 2>&1"
	@echo "  Pros: Test isolation, clean scope"
	@echo "  Cons: ~50ms overhead per test"
	@echo ""
	@echo "Dynamic include approach:"
	@echo "  Each test: Direct execution via generated rules"
	@echo "  Pros: No subprocess overhead, parallel-friendly"
	@echo "  Cons: Must manage variable isolation manually"
	@echo ""
	@echo "Hybrid approach (recommended):"
	@echo "  Orchestration: Generated rules (no recursion)"
	@echo "  Test execution: Still uses \$$(MAKE) (keeps isolation)"
	@echo "  Pros: Best of both worlds"
	@echo "  Cons: Slightly more complex"
