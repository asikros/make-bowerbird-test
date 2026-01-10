test-compare-strings-equal:
	$(call bowerbird::test::compare-strings,alpha,alpha)


test-compare-strings-not-equal:
	! $(call bowerbird::test::compare-strings,alpha,beta)


test-compare-strings-not-equal-leading-whitespace:
	! $(call bowerbird::test::compare-strings,alpha, alpha)


test-compare-strings-not-equal-trailing-whitespace:
	! $(call bowerbird::test::compare-strings,alpha,alpha )


test-compare-strings-not-equal-first-empty:
	! $(call bowerbird::test::compare-strings,,beta)


test-compare-strings-not-equal-second-empty:
	! $(call bowerbird::test::compare-strings,alpha,)


test-compare-strings-not-equal-both-empty:
	$(call bowerbird::test::compare-strings,,)


test-compare-strings-case-sensitive:
	! $(call bowerbird::test::compare-strings,Alpha,alpha)


test-compare-strings-special-chars:
	$(call bowerbird::test::compare-strings,special @ # chars,special @ # chars)


test-compare-strings-multiword:
	$(call bowerbird::test::compare-strings,multiple words here,multiple words here)


test-compare-strings-multiword-not-equal:
	! $(call bowerbird::test::compare-strings,multiple words here,multiple words there)


test-compare-strings-with-equals-sign:
	$(call bowerbird::test::compare-strings,key=value,key=value)


test-compare-strings-with-path:
	$(call bowerbird::test::compare-strings,/path/to/file.txt,/path/to/file.txt)


test-compare-strings-with-commas:
	$(call bowerbird::test::compare-strings,alpha$(bowerbird::test::COMMA)beta,alpha$(bowerbird::test::COMMA)beta)


test-compare-strings-with-dollar-sign:
	$(call bowerbird::test::compare-strings,$$VAR,$$VAR)


test-compare-strings-error-message:
	@mkdir -p $(WORKDIR_TEST)/$@
	@output=$$($(call bowerbird::test::compare-strings,actual,expected) 2>&1 || true); \
		echo "$$output" | grep -q "ERROR: Failed string comparison: 'actual' != 'expected'"


test-compare-strings-error-to-stderr:
	@mkdir -p $(WORKDIR_TEST)/$@
	@output=$$($(call bowerbird::test::compare-strings,foo,bar) 2>&1 || true); \
		test -n "$$output"


test-compare-strings-error-has-prefix:
	@output=$$($(call bowerbird::test::compare-strings,a,b) 2>&1 || true); \
		echo "$$output" | grep -q "^ERROR:"
