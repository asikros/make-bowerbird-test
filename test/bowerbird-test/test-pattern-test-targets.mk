$(call bowerbird::test::pattern-test-files,mock*.mk)
$(call bowerbird::test::pattern-test-targets,test*alpha*)
$(call bowerbird::test::suite,mock-test-pattern-test-targets-alpha-runner,test/mock-tests)
test-pattern-test-targets-alpha:
	$(call bowerbird::test::compare-sets,\
			$(sort $(BOWERBIRD_TEST/TARGETS/mock-$@-runner)),\
			$(sort test-find-files-alpha-1 test-find-files-alpha-2))


$(call bowerbird::test::pattern-test-files,mock*.mk)
$(call bowerbird::test::pattern-test-targets,test*beta*)
$(call bowerbird::test::suite,mock-test-pattern-test-targets-beta-runner,test/mock-tests)
test-pattern-test-targets-beta:
	$(call bowerbird::test::compare-sets,\
			$(sort $(BOWERBIRD_TEST/TARGETS/mock-$@-runner)),\
			$(sort test-find-files-beta-1 test-find-files-beta-2))


$(call bowerbird::test::pattern-test-files,mock*.mk)
$(call bowerbird::test::pattern-test-targets,test*gamma*)
$(call bowerbird::test::suite,mock-test-pattern-test-targets-gamma-runner,test/mock-tests)
test-pattern-test-targets-gamma:
	$(call bowerbird::test::compare-sets,\
			$(sort $(BOWERBIRD_TEST/TARGETS/mock-$@-runner)),\
			$(sort test-find-files-gamma-1 test-find-files-gamma-2))


$(call bowerbird::test::pattern-test-files,mock*.mk)
$(call bowerbird::test::pattern-test-targets,no-match)
$(call bowerbird::test::suite,mock-test-pattern-test-targets-no-match-runner,test/mock-tests)
test-pattern-test-targets-no-match:
	$(call bowerbird::test::compare-sets,$(sort $(BOWERBIRD_TEST/TARGETS/mock-$@-runner)),)
