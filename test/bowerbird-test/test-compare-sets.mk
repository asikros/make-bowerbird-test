test-compare-sets-one-element-equal-same-elements:
	$(call bowerbird::test::compare-sets,alpha,alpha)


test-compare-sets-one-element-equal-leading-whitespace:
	$(call bowerbird::test::compare-sets,alpha, alpha)


test-compare-sets-one-element-equal-trailing-whitespace:
	$(call bowerbird::test::compare-sets,alpha,alpha )


test-compare-sets-one-element-not-equal-different-elements:
	! $(call bowerbird::test::compare-sets,alpha,beta)


test-compare-sets-one-element-not-equal-first-empty:
	! $(call bowerbird::test::compare-sets,,beta)


test-compare-sets-one-element-not-equal-second-empty:
	! $(call bowerbird::test::compare-sets,alpha,)


test-compare-sets-one-element-not-equal-both-empty:
	$(call bowerbird::test::compare-sets,,)


test-compare-sets-multiple-elements-equal-same-order:
	$(call bowerbird::test::compare-sets,alpha beta,alpha beta)


test-compare-sets-multiple-elements-equal-different-order:
	$(call bowerbird::test::compare-sets,alpha beta,beta alpha)


test-compare-sets-multiple-elements-equal-leading-whitespace:
	$(call bowerbird::test::compare-sets,alpha beta, alpha beta)


test-compare-sets-multiple-elements-equal-trailing-whitespace:
	$(call bowerbird::test::compare-sets,alpha beta,alpha beta )


test-compare-sets-multiple-element-not-equal-extra-element:
	! $(call bowerbird::test::compare-sets,alpha beta,alpha beta gamma)


test-compare-sets-multiple-element-not-equal-missing-element:
	! $(call bowerbird::test::compare-sets,alpha beta gamma,alpha beta)


test-compare-sets-duplicates-collapsed:
	$(call bowerbird::test::compare-sets,alpha alpha beta,alpha beta)
