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
