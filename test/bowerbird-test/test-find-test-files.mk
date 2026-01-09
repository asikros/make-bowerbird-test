define bowerbird::test::mock-test-files
$(call bowerbird::test::find-test-files,test/mock-tests,mock-test*.mk)
endef


test-find-test-files-count:
	$(call bowerbird::test::compare-strings,7,$(words $(bowerbird::test::mock-test-files)))


test-find-test-files-alpha:
	$(call bowerbird::test::compare-sets,$(filter %alpha.mk,$(bowerbird::test::mock-test-files)),$(abspath test/mock-tests/alpha/mock-test-alpha.mk))


test-find-test-files-beta:
	$(call bowerbird::test::compare-sets,$(filter %beta.mk,$(bowerbird::test::mock-test-files)),$(abspath test/mock-tests/alpha/beta/mock-test-beta.mk))


test-find-test-files-gamma:
	$(call bowerbird::test::compare-sets,$(filter %gamma.mk,$(bowerbird::test::mock-test-files)),$(abspath test/mock-tests/alpha/beta/gamma/mock-test-gamma.mk))


test-find-test-files-empty:
	$(call bowerbird::test::compare-sets,$(filter %empty.mk,$(bowerbird::test::mock-test-files)),$(abspath test/mock-tests/mock-test-empty.mk))


test-find-test-files-deps:
	$(call bowerbird::test::compare-sets,$(filter %deps.mk,$(bowerbird::test::mock-test-files)),$(abspath test/mock-tests/mock-test-deps.mk))


test-find-test-files-nonexistent-dir:
	$(call bowerbird::test::compare-strings,,$(call bowerbird::test::find-test-files,nonexistent-dir,*.mk))


test-find-test-files-empty-dir:
	$(call bowerbird::test::compare-strings,,$(call bowerbird::test::find-test-files,test/mock-tests/empty-dir,*.mk))


test-find-test-files-no-match:
	$(call bowerbird::test::compare-strings,,$(call bowerbird::test::find-test-files,test/mock-tests,no-match-pattern*.mk))


test-find-test-files-pattern-alpha:
	$(call bowerbird::test::compare-strings,1,$(words $(call bowerbird::test::find-test-files,test/mock-tests,*alpha.mk)))


test-find-test-files-pattern-all-mk:
	$(call bowerbird::test::compare-strings,7,$(words $(call bowerbird::test::find-test-files,test/mock-tests,*.mk)))


test-find-test-files-subdir-only:
	$(call bowerbird::test::compare-strings,3,$(words $(call bowerbird::test::find-test-files,test/mock-tests/alpha,*.mk)))


test-find-test-files-total-count:
	$(call bowerbird::test::compare-strings,7,$(words $(call bowerbird::test::find-test-files,test/mock-tests,mock-test*.mk)))
