_PATH := $(dir $(lastword $(MAKEFILE_LIST)))
# Mock shell logic embedded directly to avoid macOS quarantine issues with script files
# This evaluates to: sh -c 'eval "CMD=\"\${$#}\""; echo "$CMD" >> "$RESULTS"' sh
BOWERBIRD_MOCK_SHELL_INLINE := sh -c 'eval "COMMAND=\"\$${$$\#}\""; echo "$$COMMAND" >> "$${BOWERBIRD_MOCK_RESULTS:?BOWERBIRD_MOCK_RESULTS must be set}"' sh
include $(_PATH)/src/bowerbird-test/bowerbird-constants.mk
include $(_PATH)/src/bowerbird-test/bowerbird-compare.mk
include $(_PATH)/src/bowerbird-test/bowerbird-find.mk
include $(_PATH)/src/bowerbird-test/bowerbird-test-runner.mk
include $(_PATH)/src/bowerbird-test/bowerbird-mock.mk