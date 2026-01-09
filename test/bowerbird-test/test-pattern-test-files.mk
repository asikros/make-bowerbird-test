$(call bowerbird::test::pattern-test-files,*alpha.mk)
$(call bowerbird::test::suite,mock-test-pattern-test-files-alpha-runner,test/mock-tests)
test-pattern-test-files-alpha:
	$(call bowerbird::test::compare-sets,$(BOWERBIRD_TEST/FILES/mock-$@-runner),\
			$(abspath test/mock-tests/alpha/mock-test-alpha.mk))


$(call bowerbird::test::pattern-test-files,*beta.mk)
$(call bowerbird::test::suite,mock-test-pattern-test-files-beta-runner,test/mock-tests)
test-pattern-test-files-beta:
	$(call bowerbird::test::compare-sets,\
			$(BOWERBIRD_TEST/FILES/mock-$@-runner),\
			$(abspath test/mock-tests/alpha/beta/mock-test-beta.mk))


$(call bowerbird::test::pattern-test-files,*gamma.mk)
$(call bowerbird::test::suite,mock-test-pattern-test-files-gamma-runner,test/mock-tests)
test-pattern-test-files-gamma:
	$(call bowerbird::test::compare-sets,\
			$(BOWERBIRD_TEST/FILES/mock-$@-runner),\
			$(abspath test/mock-tests/alpha/beta/gamma/mock-test-gamma.mk))


$(call bowerbird::test::pattern-test-files,no-match.mk)
$(call bowerbird::test::suite,mock-test-pattern-test-files-no-match-runner,test/mock-tests)
test-pattern-test-files-no-match:
	$(call bowerbird::test::compare-sets,$(BOWERBIRD_TEST/FILES/mock-$@-runner),)
