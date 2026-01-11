test-find-test-targets-alpha-targets:
	$(call bowerbird::test::compare-sets,\
		$(call bowerbird::test::find-test-targets,test/mock-tests/alpha/mock-test-alpha.mk,test*),\
		test-find-files-alpha-1 test-find-files-alpha-2)


test-find-test-targets-alpha-count:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/alpha/mock-test-alpha.mk,test*)))


test-find-test-targets-beta-targets:
	$(call bowerbird::test::compare-sets,\
		$(call bowerbird::test::find-test-targets,test/mock-tests/alpha/beta/mock-test-beta.mk,test*),\
		test-find-files-beta-1 test-find-files-beta-2)


test-find-test-targets-beta-count:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/alpha/beta/mock-test-beta.mk,test*)))


test-find-test-targets-gamma-targets:
	$(call bowerbird::test::compare-sets,\
		$(call bowerbird::test::find-test-targets,test/mock-tests/alpha/beta/gamma/mock-test-gamma.mk,test*),\
		test-find-files-gamma-1 test-find-files-gamma-2)


test-find-test-targets-gamma-count:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/alpha/beta/gamma/mock-test-gamma.mk,test*)))


test-find-test-targets-multiple-files:
	$(call bowerbird::test::compare-sets,\
		$(call bowerbird::test::find-test-targets,\
			test/mock-tests/alpha/mock-test-alpha.mk \
			test/mock-tests/alpha/beta/mock-test-beta.mk \
			test/mock-tests/alpha/beta/gamma/mock-test-gamma.mk,\
			test*),\
		test-find-files-alpha-1 test-find-files-alpha-2 \
		test-find-files-beta-1 test-find-files-beta-2 \
		test-find-files-gamma-1 test-find-files-gamma-2)


test-find-test-targets-multiple-files-count:
	$(call bowerbird::test::compare-strings,6,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/alpha/mock-test-alpha.mk test/mock-tests/alpha/beta/mock-test-beta.mk test/mock-tests/alpha/beta/gamma/mock-test-gamma.mk,test*)))


test-find-test-targets-empty-file:
	$(call bowerbird::test::compare-strings,0,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-empty.mk,test*)))


test-find-test-targets-with-deps:
	$(call bowerbird::test::compare-sets,\
		$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-deps.mk,test*),\
		test-with-deps test-with-order-only test-with-pattern-dep)


test-find-test-targets-with-deps-count:
	$(call bowerbird::test::compare-strings,3,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-deps.mk,test*)))


test-find-test-targets-explicit-target:
	@echo "Explicit test target"


test-find-test-targets-discovers-explicit:
	$(call bowerbird::test::compare-strings,1,$(words $(filter test-find-test-targets-explicit-target,$(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk,test*))))


.PHONY: mock-discovery-single
mock-discovery-single:
	@echo "Single-line macro test"

define mock-discovery-single-expected
echo "Single-line macro test"
endef

$(call bowerbird::test::add-mock-test,\
	test-find-test-targets-mock-single-line,\
	mock-discovery-single,\
	mock-discovery-single-expected,)


.PHONY: mock-discovery-multi
mock-discovery-multi:
	@echo "Multi-line macro test"

define mock-discovery-multi-expected
echo "Multi-line macro test"
endef

$(call bowerbird::test::add-mock-test,\
	test-find-test-targets-mock-multi-line,\
	mock-discovery-multi,\
	mock-discovery-multi-expected,)


test-find-test-targets-discovers-mock-single:
	$(call bowerbird::test::compare-strings,1,$(words $(filter test-find-test-targets-mock-single-line,$(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk,test*))))


test-find-test-targets-discovers-mock-multi:
	$(call bowerbird::test::compare-strings,1,$(words $(filter test-find-test-targets-mock-multi-line,$(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk,test*))))


test-find-test-targets-total-count:
	$(call bowerbird::test::compare-strings,50,$(words $(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk,test*)))


test-find-test-targets-four-continuations:
	$(call bowerbird::test::compare-strings,1,$(words $(filter test-multiline-four-continuations,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-multiline.mk,test*))))


test-find-test-targets-long-name:
	$(call bowerbird::test::compare-strings,1,$(words $(filter test-this-is-a-very-long-target-name-that-tests-boundary-conditions,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-multiline.mk,test*))))


test-find-test-targets-multiline-count:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-multiline.mk,test*)))


test-find-test-targets-excludes-underscore-prefix:
	$(call bowerbird::test::compare-strings,0,$(words $(filter _test-underscore-prefix,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk,test*))))


test-find-test-targets-excludes-double-underscore-prefix:
	$(call bowerbird::test::compare-strings,0,$(words $(filter __test-double-underscore-prefix,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk,test*))))


test-find-test-targets-excludes-helper-prefix:
	$(call bowerbird::test::compare-strings,0,$(words $(filter helper-test-helper-prefix,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk,test*))))


test-find-test-targets-excludes-mock-underscore:
	$(call bowerbird::test::compare-strings,0,$(words $(filter _test-mock-prefixed-underscore,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk,test*))))


test-find-test-targets-excludes-mock-internal:
	$(call bowerbird::test::compare-strings,0,$(words $(filter __mock-prefixed-internal,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk,test*))))


test-find-test-targets-includes-valid-explicit:
	$(call bowerbird::test::compare-strings,1,$(words $(filter test-prefixed-valid-target,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk,test*))))


test-find-test-targets-includes-valid-mock:
	$(call bowerbird::test::compare-strings,1,$(words $(filter test-prefixed-mock-valid,$(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk,test*))))


test-find-test-targets-prefixed-count:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-targets,test/mock-tests/mock-test-prefixed.mk,test*)))


test-find-test-targets-sorted-output:
	@sorted="$(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk,test*)"; \
	manual_sort="$(sort $(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk,test*))"; \
	test "$$sorted" = "$$manual_sort"


test-find-test-targets-no-duplicates:
	@all="$(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk,test*)"; \
	unique="$(sort $(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk,test*))"; \
	test $(words $$all) -eq $(words $$unique)


test-find-test-targets-hyphenated-names:
	$(call bowerbird::test::compare-strings,1,$(words $(filter test-find-test-targets-hyphenated-names,$(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk,test*))))


test-find-test-targets-nonexistent-file:
	$(call bowerbird::test::compare-strings,0,$(words $(call bowerbird::test::find-test-targets,nonexistent-file.mk,test*)))


test-find-test-targets-pattern-check:
	$(call bowerbird::test::compare-strings,1,$(words $(filter check-test,$(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk,check*))))


test-find-test-targets-multiple-patterns:
	$(call bowerbird::test::compare-strings,51,$(words $(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk,test* check*)))


test-find-test-targets-non-matching-pattern:
	$(call bowerbird::test::compare-strings,0,$(words $(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk,foo*)))


test-find-test-targets-pattern-partial-match:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk,test-find-test-targets-alpha*)))


test-find-test-targets-pattern-exact-match:
	$(call bowerbird::test::compare-strings,1,$(words $(call bowerbird::test::find-test-targets,test/bowerbird-test/test-find-test-targets.mk,test-find-test-targets-alpha-targets)))


check-test:
	@echo "Check test target"


test-find-test-targets-permutation-multiple-files-multiple-patterns:
	$(call bowerbird::test::compare-strings,4,$(words $(call bowerbird::test::find-test-targets,\
		test/mock-tests/alpha/mock-test-alpha.mk \
		test/mock-tests/alpha/beta/mock-test-beta.mk,\
		test-find-files-alpha* test-find-files-beta*)))


test-find-test-targets-permutation-some-files-match:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-targets,\
		test/mock-tests/alpha/mock-test-alpha.mk \
		test/mock-tests/mock-test-empty.mk,\
		test*)))


test-find-test-targets-permutation-some-patterns-match:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-targets,\
		test/mock-tests/alpha/mock-test-alpha.mk,\
		test-find-files-alpha* nomatch*)))


test-find-test-targets-permutation-no-pattern-matches:
	$(call bowerbird::test::compare-strings,0,$(words $(call bowerbird::test::find-test-targets,\
		test/mock-tests/alpha/mock-test-alpha.mk \
		test/mock-tests/alpha/beta/mock-test-beta.mk,\
		nomatch* nofiles*)))


test-find-test-targets-permutation-pattern-matches-all-files:
	$(call bowerbird::test::compare-strings,6,$(words $(call bowerbird::test::find-test-targets,\
		test/mock-tests/alpha/mock-test-alpha.mk \
		test/mock-tests/alpha/beta/mock-test-beta.mk \
		test/mock-tests/alpha/beta/gamma/mock-test-gamma.mk,\
		test*)))


test-find-test-targets-permutation-pattern-matches-one-file:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-targets,\
		test/mock-tests/alpha/mock-test-alpha.mk \
		test/mock-tests/alpha/beta/mock-test-beta.mk,\
		test-find-files-alpha*)))


test-find-test-targets-permutation-overlapping-patterns:
	@all=$$(call bowerbird::test::find-test-targets,\
		test/mock-tests/alpha/mock-test-alpha.mk,\
		test* test-find-files-alpha*); \
	unique=$$(sort $$all); \
	test $$(words $$all) -eq $$(words $$unique)


test-find-test-targets-permutation-unique-matches-per-file:
	$(call bowerbird::test::compare-strings,4,$(words $(call bowerbird::test::find-test-targets,\
		test/mock-tests/alpha/mock-test-alpha.mk \
		test/mock-tests/alpha/beta/mock-test-beta.mk,\
		test-find-files-alpha* test-find-files-beta*)))


test-find-test-targets-permutation-mixed-empty-and-populated:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-targets,\
		test/mock-tests/mock-test-empty.mk \
		test/mock-tests/alpha/mock-test-alpha.mk \
		test/mock-tests/mock-test-empty.mk,\
		test*)))


test-find-test-targets-permutation-three-files-two-patterns:
	$(call bowerbird::test::compare-strings,4,$(words $(call bowerbird::test::find-test-targets,\
		test/mock-tests/alpha/mock-test-alpha.mk \
		test/mock-tests/alpha/beta/mock-test-beta.mk \
		test/mock-tests/alpha/beta/gamma/mock-test-gamma.mk,\
		test-find-files-alpha* test-find-files-gamma*)))


test-find-test-targets-permutation-pattern-order-irrelevant:
	@result1=$$(call bowerbird::test::find-test-targets,\
		test/mock-tests/alpha/mock-test-alpha.mk,\
		test-find-files-alpha-1 test-find-files-alpha-2); \
	result2=$$(call bowerbird::test::find-test-targets,\
		test/mock-tests/alpha/mock-test-alpha.mk,\
		test-find-files-alpha-2 test-find-files-alpha-1); \
	test "$$result1" = "$$result2"


test-find-test-targets-permutation-file-order-irrelevant:
	@result1=$$(call bowerbird::test::find-test-targets,\
		test/mock-tests/alpha/mock-test-alpha.mk \
		test/mock-tests/alpha/beta/mock-test-beta.mk,\
		test*); \
	result2=$$(call bowerbird::test::find-test-targets,\
		test/mock-tests/alpha/beta/mock-test-beta.mk \
		test/mock-tests/alpha/mock-test-alpha.mk,\
		test*); \
	test "$$result1" = "$$result2"
