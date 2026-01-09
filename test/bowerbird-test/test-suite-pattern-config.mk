# Unit tests for bowerbird::test::pattern-test-files and bowerbird::test::pattern-test-targets


# Test: pattern-test-files sets file-pattern-user config
test-suite-pattern-files-sets-config:
	$(call bowerbird::test::pattern-test-files,custom*.mk)
	$(call bowerbird::test::compare-strings,$(bowerbird-test.config.file-pattern-user),custom*.mk)


# Test: pattern-test-files accepts wildcard patterns
test-suite-pattern-files-accepts-wildcards:
	$(call bowerbird::test::pattern-test-files,*_test.mk)
	$(call bowerbird::test::compare-strings,$(bowerbird-test.config.file-pattern-user),*_test.mk)


# Test: pattern-test-files accepts multiple wildcards
test-suite-pattern-files-multiple-wildcards:
	$(call bowerbird::test::pattern-test-files,test*spec*.mk)
	$(call bowerbird::test::compare-strings,$(bowerbird-test.config.file-pattern-user),test*spec*.mk)


# Test: pattern-test-files can set simple pattern
test-suite-pattern-files-simple-pattern:
	$(call bowerbird::test::pattern-test-files,mytest.mk)
	$(call bowerbird::test::compare-strings,$(bowerbird-test.config.file-pattern-user),mytest.mk)


# Test: pattern-test-targets sets target-pattern-user config
test-suite-pattern-targets-sets-config:
	$(call bowerbird::test::pattern-test-targets,custom*)
	$(call bowerbird::test::compare-strings,$(bowerbird-test.config.target-pattern-user),custom*)


# Test: pattern-test-targets accepts wildcard patterns
test-suite-pattern-targets-accepts-wildcards:
	$(call bowerbird::test::pattern-test-targets,*_check)
	$(call bowerbird::test::compare-strings,$(bowerbird-test.config.target-pattern-user),*_check)


# Test: pattern-test-targets accepts prefix patterns
test-suite-pattern-targets-prefix-pattern:
	$(call bowerbird::test::pattern-test-targets,verify-*)
	$(call bowerbird::test::compare-strings,$(bowerbird-test.config.target-pattern-user),verify-*)


# Test: pattern-test-targets can set simple pattern
test-suite-pattern-targets-simple-pattern:
	$(call bowerbird::test::pattern-test-targets,mytest)
	$(call bowerbird::test::compare-strings,$(bowerbird-test.config.target-pattern-user),mytest)


# Test: Resets are independent (files doesn't affect targets)
test-suite-pattern-independence:
	$(call bowerbird::test::pattern-test-files,file*.mk)
	$(call bowerbird::test::pattern-test-targets,target*)
	$(call bowerbird::test::compare-strings,$(bowerbird-test.config.file-pattern-user),file*.mk)
	$(call bowerbird::test::compare-strings,$(bowerbird-test.config.target-pattern-user),target*)
