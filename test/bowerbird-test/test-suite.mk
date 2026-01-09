# $(call bowerbird::test::pattern-test-files,mock-test*.mk)
# $(call bowerbird::test::pattern-test-targets,test*)
# $(call bowerbird::test::suite,mock-generate-runner,test/mock-tests)


# test-generate-runner-mock-test-files:
# 	$(call bowerbird::test::compare-sets,\
# 			$(BOWERBIRD_TEST/FILES/mock-generate-runner),\
# 			$(abspath test/mock-tests/alpha/beta/gamma/mock-test-gamma.mk) \
# 					$(abspath test/mock-tests/alpha/beta/mock-test-beta.mk) \
# 					$(abspath test/mock-tests/alpha/mock-test-alpha.mk) \
# 					$(abspath test/mock-tests/mock-test-deps.mk) \
# 					$(abspath test/mock-tests/mock-test-empty.mk) \
# 					$(abspath test/mock-tests/mock-test-multiline.mk) \
# 					$(abspath test/mock-tests/mock-test-prefixed.mk))


# test-generate-runner-mock-test-targets:
# 	$(call bowerbird::test::compare-sets,\
# 			$(sort $(BOWERBIRD_TEST/TARGETS/mock-generate-runner)),\
# 			$(sort test-find-files-gamma-1 test-find-files-gamma-2 \
# 					test-find-files-beta-1 test-find-files-beta-2 \
# 					test-find-files-alpha-1 test-find-files-alpha-2 \
# 					test-with-deps test-with-order-only test-with-pattern-dep \
# 					test-this-is-a-very-long-target-name-that-tests-boundary-conditions \
# 					test-multiline-four-continuations \
# 					test-prefixed-valid-target test-prefixed-mock-valid))


# test-generate-runner-mock-test-include: $(BOWERBIRD_TEST/TARGETS/mock-generate-runner)


# test-generate-runner-mock-test-runner-logs:
# 	$(foreach f,alpha-1 alpha-2 beta-1 beta-2 gamma-1 gamma-2,\
# 		test ! -f $(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/mock-generate-runner/test-find-files-$(f).$(BOWERBIRD_TEST/CONSTANT/EXT_LOG) || \
# 		rm -f  $(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/mock-generate-runner/test-find-files-$(f).$(BOWERBIRD_TEST/CONSTANT/EXT_LOG);)
# 	$(foreach f,alpha-1 alpha-2 beta-1 beta-2 gamma-1 gamma-2,\
# 		! test -f $(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/mock-generate-runner/test-find-files-$(f).$(BOWERBIRD_TEST/CONSTANT/EXT_LOG);)
# 	$(MAKE) mock-generate-runner 2>/dev/null
# 	$(foreach f,alpha-1 alpha-2 beta-1 beta-2 gamma-1 gamma-2,\
# 		test -f $(BOWERBIRD_TEST/CONSTANT/WORKDIR_LOGS)/mock-generate-runner/test-find-files-$(f).$(BOWERBIRD_TEST/CONSTANT/EXT_LOG);)


# test-generate-runner-mock-test-runner-results:
# 	$(foreach f,alpha-1 alpha-2 beta-1 beta-2 gamma-1 gamma-2,\
# 		test ! -f $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-generate-runner/test-find-files-$(f).$(BOWERBIRD_TEST/CONSTANT/EXT_PASS) || \
# 		rm -f  $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-generate-runner/test-find-files-$(f).$(BOWERBIRD_TEST/CONSTANT/EXT_PASS);)
# 	$(foreach f,alpha-1 alpha-2 beta-1 beta-2 gamma-1 gamma-2,\
# 		! test -f $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-generate-runner/test-find-files-$(f).$(BOWERBIRD_TEST/CONSTANT/EXT_PASS);)
# 	$(MAKE) mock-generate-runner 2>/dev/null
# 	$(foreach f,alpha-1 alpha-2 beta-1 beta-2 gamma-1 gamma-2,\
# 		test -f $(BOWERBIRD_TEST/CONSTANT/WORDDIR_RESULTS)/mock-generate-runner/test-find-files-$(f).$(BOWERBIRD_TEST/CONSTANT/EXT_PASS);)
