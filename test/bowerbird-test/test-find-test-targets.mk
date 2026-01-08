test-find-test-targets-alpha-targets:
	$(call bowerbird::test::compare-sets,\
		$(call bowerbird::test::find-test-targets,test/mock-tests/alpha/mock-test-alpha.mk),\
		test-find-files-alpha-1 test-find-files-alpha-2)

test-find-test-targets-alpha-count:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/alpha/mock-test-alpha.mk)))

test-find-test-targets-beta-targets:
	$(call bowerbird::test::compare-sets,\
		$(call bowerbird::test::find-test-targets,test/mock-tests/alpha/beta/mock-test-beta.mk),\
		test-find-files-beta-1 test-find-files-beta-2)

test-find-test-targets-beta-count:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/alpha/beta/mock-test-beta.mk)))

test-find-test-targets-gamma-targets:
	$(call bowerbird::test::compare-sets,\
		$(call bowerbird::test::find-test-targets,test/mock-tests/alpha/beta/gamma/mock-test-gamma.mk),\
		test-find-files-gamma-1 test-find-files-gamma-2)

test-find-test-targets-gamma-count:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/alpha/beta/gamma/mock-test-gamma.mk)))

test-find-test-targets-multiple-files:
	$(call bowerbird::test::compare-sets,\
		$(call bowerbird::test::find-test-targets,\
			test/mock-tests/alpha/mock-test-alpha.mk \
			test/mock-tests/alpha/beta/mock-test-beta.mk \
			test/mock-tests/alpha/beta/gamma/mock-test-gamma.mk),\
		test-find-files-alpha-1 test-find-files-alpha-2 \
		test-find-files-beta-1 test-find-files-beta-2 \
		test-find-files-gamma-1 test-find-files-gamma-2)

test-find-test-targets-multiple-files-count:
	$(call bowerbird::test::compare-strings,6,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/alpha/mock-test-alpha.mk test/mock-tests/alpha/beta/mock-test-beta.mk test/mock-tests/alpha/beta/gamma/mock-test-gamma.mk)))

test-find-test-targets-empty-file:
	$(call bowerbird::test::compare-strings,0,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-empty.mk)))

test-find-test-targets-with-deps:
	$(call bowerbird::test::compare-sets,\
		$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-deps.mk),\
		test-with-deps test-with-order-only test-with-pattern-dep)

test-find-test-targets-with-deps-count:
	$(call bowerbird::test::compare-strings,3,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-deps.mk)))

test-find-test-targets-explicit-target:
	@echo "Explicit test target"

test-find-test-targets-discovers-explicit:
	$(call bowerbird::test::compare-strings,1,$(words $(filter test-find-test-targets-explicit-target,$(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk))))

.PHONY: mock-discovery-single
mock-discovery-single:
	@echo "Single-line macro test"

define mock-discovery-single-expected
echo Single-line macro test
endef

$(call bowerbird::test::add-mock-test,\
	test-find-test-targets-mock-single-line,\
	mock-discovery-single,\
	mock-discovery-single-expected,)

.PHONY: mock-discovery-multi
mock-discovery-multi:
	@echo "Multi-line macro test"

define mock-discovery-multi-expected
echo Multi-line macro test
endef

$(call bowerbird::test::add-mock-test,\
	test-find-test-targets-mock-multi-line,\
	mock-discovery-multi,\
	mock-discovery-multi-expected,)

test-find-test-targets-discovers-mock-single:
	$(call bowerbird::test::compare-strings,1,$(words $(filter test-find-test-targets-mock-single-line,$(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk))))

test-find-test-targets-discovers-mock-multi:
	$(call bowerbird::test::compare-strings,1,$(words $(filter test-find-test-targets-mock-multi-line,$(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk))))

test-find-test-targets-total-count:
	$(call bowerbird::test::compare-strings,29,$(words $(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk)))

test-find-test-targets-four-continuations:
	$(call bowerbird::test::compare-strings,1,$(words $(filter test-multiline-four-continuations,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-multiline.mk))))

test-find-test-targets-long-name:
	$(call bowerbird::test::compare-strings,1,$(words $(filter test-this-is-a-very-long-target-name-that-tests-boundary-conditions,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-multiline.mk))))

test-find-test-targets-multiline-count:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-multiline.mk)))

test-find-test-targets-excludes-underscore-prefix:
	$(call bowerbird::test::compare-strings,0,$(words $(filter _test-underscore-prefix,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk))))

test-find-test-targets-excludes-double-underscore-prefix:
	$(call bowerbird::test::compare-strings,0,$(words $(filter __test-double-underscore-prefix,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk))))

test-find-test-targets-excludes-helper-prefix:
	$(call bowerbird::test::compare-strings,0,$(words $(filter helper-test-helper-prefix,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk))))

test-find-test-targets-excludes-mock-underscore:
	$(call bowerbird::test::compare-strings,0,$(words $(filter _test-mock-prefixed-underscore,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk))))

test-find-test-targets-excludes-mock-internal:
	$(call bowerbird::test::compare-strings,0,$(words $(filter __mock-prefixed-internal,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk))))

test-find-test-targets-includes-valid-explicit:
	$(call bowerbird::test::compare-strings,1,$(words $(filter test-prefixed-valid-target,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk))))

test-find-test-targets-includes-valid-mock:
	$(call bowerbird::test::compare-strings,1,$(words $(filter test-prefixed-mock-valid,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk))))

test-find-test-targets-prefixed-count:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk)))
