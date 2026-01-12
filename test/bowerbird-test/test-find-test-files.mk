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


test-find-test-files-case-sensitive:
	$(call bowerbird::test::compare-strings,0,$(words $(call bowerbird::test::find-test-files,test/mock-tests,MOCK-TEST*.mk)))


test-find-test-files-multiple-wildcards:
	$(call bowerbird::test::compare-strings,7,$(words $(call bowerbird::test::find-test-files,test/mock-tests,*-test-*.mk)))


test-find-test-files-absolute-path-input:
	$(call bowerbird::test::compare-strings,7,$(words $(call bowerbird::test::find-test-files,$(abspath test/mock-tests),mock-test*.mk)))


test-find-test-files-returns-absolute-paths:
	@test -n "$(filter /%,$(call bowerbird::test::find-test-files,test/mock-tests,mock-test*.mk))"


test-find-test-files-multiple-patterns-count:
	$(call bowerbird::test::compare-strings,7,$(words $(call bowerbird::test::find-test-files,test/mock-tests,mock-test*.mk test*.mk)))


test-find-test-files-multiple-patterns-combined:
	$(call bowerbird::test::compare-strings,7,$(words $(call bowerbird::test::find-test-files,test/mock-tests,*alpha.mk *beta.mk *gamma.mk *deps.mk *empty.mk *multiline.mk *prefixed.mk)))


test-find-test-files-multiple-patterns-no-duplicates:
	@all="$(call bowerbird::test::find-test-files,test/mock-tests,mock-test*.mk *.mk)"; \
	unique=$$(printf '%s\n' $$all | sort | tr '\n' ' '); \
	all_count=$$(printf '%s\n' $$all | wc -w | tr -d ' '); \
	unique_count=$$(printf '%s\n' $$unique | wc -w | tr -d ' '); \
	test $$all_count -eq $$unique_count


test-find-test-files-multiple-patterns-sorted:
	@sorted="$(call bowerbird::test::find-test-files,test/mock-tests,mock-test*.mk test*.mk)"; \
	manual_sort=$$(printf '%s\n' $$sorted | sort | tr '\n' ' ' | sed 's/ $$//' ); \
	test "$$sorted" = "$$manual_sort"


test-find-test-files-multiple-patterns-partial-overlap:
	$(call bowerbird::test::compare-strings,7,$(words $(call bowerbird::test::find-test-files,test/mock-tests,mock-test-*.mk *-test-*.mk)))


test-find-test-files-multiple-paths-count:
	$(call bowerbird::test::compare-strings,3,$(words $(call bowerbird::test::find-test-files,test/mock-tests/alpha test/mock-tests/alpha/beta,*.mk)))


test-find-test-files-multiple-paths-nested:
	$(call bowerbird::test::compare-strings,3,$(words $(call bowerbird::test::find-test-files,test/mock-tests/alpha test/mock-tests/alpha/beta test/mock-tests/alpha/beta/gamma,mock-test*.mk)))


test-find-test-files-multiple-paths-no-duplicates:
	@all="$(call bowerbird::test::find-test-files,test/mock-tests test/mock-tests/alpha,*.mk)"; \
	unique=$$(printf '%s\n' $$all | sort | tr '\n' ' '); \
	all_count=$$(printf '%s\n' $$all | wc -w | tr -d ' '); \
	unique_count=$$(printf '%s\n' $$unique | wc -w | tr -d ' '); \
	test $$all_count -eq $$unique_count


test-find-test-files-multiple-paths-and-patterns:
	$(call bowerbird::test::compare-strings,2,$(words $(call bowerbird::test::find-test-files,test/mock-tests/alpha test/mock-tests/alpha/beta,*alpha.mk *beta.mk)))


test-find-test-files-multiple-paths-empty-path:
	$(call bowerbird::test::compare-strings,1,$(words $(call bowerbird::test::find-test-files,test/mock-tests/empty-dir test/mock-tests/alpha,*alpha.mk)))
