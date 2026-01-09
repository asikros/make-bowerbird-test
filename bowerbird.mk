_PATH := $(dir $(lastword $(MAKEFILE_LIST)))
include $(_PATH)/src/bowerbird-test/bowerbird-constants.mk
include $(_PATH)/src/bowerbird-test/bowerbird-compare.mk
include $(_PATH)/src/bowerbird-test/bowerbird-find.mk
include $(_PATH)/src/bowerbird-test/bowerbird-test-runner.mk
include $(_PATH)/src/bowerbird-test/bowerbird-mock.mk