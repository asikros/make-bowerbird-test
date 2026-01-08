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
	$(call bowerbird::test::compare-strings,15,$(words $(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk)))
