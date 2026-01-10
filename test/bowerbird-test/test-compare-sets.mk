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


test-compare-sets-many-duplicates:
	$(call bowerbird::test::compare-sets,alpha alpha alpha beta beta,alpha beta)


test-compare-sets-multiple-whitespace:
	$(call bowerbird::test::compare-sets,alpha  beta,alpha beta)


test-compare-sets-many-elements:
	$(call bowerbird::test::compare-sets,a b c d e f g h,h g f e d c b a)


test-compare-sets-special-chars:
	$(call bowerbird::test::compare-sets,@file #tag,#tag @file)


test-compare-sets-error-message:
	@mkdir -p $(WORKDIR_TEST)/$@
	@output=$$($(call bowerbird::test::compare-sets,alpha beta,gamma delta) 2>&1 || true); \
		echo "$$output" | grep -q "ERROR: Failed list comparison: 'alpha beta' != 'delta gamma'"


test-compare-sets-error-to-stderr:
	@mkdir -p $(WORKDIR_TEST)/$@
	@output=$$($(call bowerbird::test::compare-sets,one,two) 2>&1 || true); \
		test -n "$$output"


test-compare-sets-error-has-prefix:
	@output=$$($(call bowerbird::test::compare-sets,a,b) 2>&1 || true); \
		echo "$$output" | grep -q "^ERROR:"
