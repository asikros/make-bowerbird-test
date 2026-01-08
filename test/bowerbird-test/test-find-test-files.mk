define bowerbird::test::mock-test-files
$(call bowerbird::test::find-test-files,test/mock-tests,mock-test*.mk)
endef

test-find-test-files-num-files:
	$(call bowerbird::test::compare-strings,3,$(words $(bowerbird::test::mock-test-files)))

test-find-test-files-alpha:
	$(call bowerbird::test::compare-sets,$(filter %alpha.mk,$(bowerbird::test::mock-test-files)),$(abspath test/mock-tests/alpha/mock-test-alpha.mk))

test-find-test-files-beta:
	$(call bowerbird::test::compare-sets,$(filter %beta.mk,$(bowerbird::test::mock-test-files)),$(abspath test/mock-tests/alpha/beta/mock-test-beta.mk))

test-find-test-files-gamma:
	$(call bowerbird::test::compare-sets,$(filter %gamma.mk,$(bowerbird::test::mock-test-files)),$(abspath test/mock-tests/alpha/beta/gamma/mock-test-gamma.mk))

test-find-test-files-nonexistent-dir:
	$(call bowerbird::test::compare-strings,,$(call bowerbird::test::find-test-files,nonexistent-dir,*.mk))

test-find-test-files-no-match:
	$(call bowerbird::test::compare-strings,,$(call bowerbird::test::find-test-files,test/mock-tests,no-match-pattern*.mk))

test-find-test-files-different-pattern:
	$(call bowerbird::test::compare-strings,1,$(words $(call bowerbird::test::find-test-files,test/mock-tests,*alpha.mk)))
