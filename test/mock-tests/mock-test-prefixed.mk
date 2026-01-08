# Test file for verifying prefix filtering in test discovery
# These targets should NOT be discovered as they don't start with 'test'

# Underscore prefix - should NOT match
_test-underscore-prefix:
	@:

# Double underscore prefix - should NOT match
__test-double-underscore-prefix:
	@:

# Helper prefix - should NOT match
helper-test-helper-prefix:
	@:

# Internal prefix - should NOT match
internal-test-internal-prefix:
	@:

# This one SHOULD match - starts with 'test'
test-prefixed-valid-target:
	@:

# add-mock-test with non-test prefix - should NOT match
.PHONY: mock-prefixed-target
mock-prefixed-target:
	@echo "mock target"

define mock-prefixed-expected
echo mock target
endef

$(call bowerbird::test::add-mock-test,\
	_test-mock-prefixed-underscore,\
	mock-prefixed-target,\
	mock-prefixed-expected,)

$(call bowerbird::test::add-mock-test,\
	__mock-prefixed-internal,\
	mock-prefixed-target,\
	mock-prefixed-expected,)

# add-mock-test with valid test prefix - SHOULD match
$(call bowerbird::test::add-mock-test,\
	test-prefixed-mock-valid,\
	mock-prefixed-target,\
	mock-prefixed-expected,)
