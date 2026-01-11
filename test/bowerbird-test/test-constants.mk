test-constants-comma-defined:
	@test -n "$(bowerbird::test::COMMA)"


test-constants-comma-value:
	@test "$(bowerbird::test::COMMA)" = ","


test-constants-comma-in-subst:
	$(call bowerbird::test::compare-strings,$(subst $(bowerbird::test::COMMA), ,a$(bowerbird::test::COMMA)b$(bowerbird::test::COMMA)c),a b c)


test-constants-comma-multiple-subst:
	$(call bowerbird::test::compare-strings,\
		$(subst $(bowerbird::test::COMMA),,1$(bowerbird::test::COMMA)2$(bowerbird::test::COMMA)3$(bowerbird::test::COMMA)4),\
		1234)


test-constants-comma-as-separator:
	$(call bowerbird::test::compare-sets,\
		$(subst $(bowerbird::test::COMMA), ,alpha$(bowerbird::test::COMMA)beta$(bowerbird::test::COMMA)gamma),\
		alpha beta gamma)


define define-constants-newline-in-subst
line1
line2
line3
endef

test-constants-newline-defined:
	$(call bowerbird::test::compare-strings,\
		$(words $(subst $(bowerbird::test::NEWLINE), ,$(define-constants-newline-in-subst))),\
		3)


test-constants-newline-multiline:
	@result=$$(printf '%b' '$(subst $(bowerbird::test::NEWLINE),\n,$(define-constants-newline-in-subst))'); \
	lines=$$(echo "$$result" | wc -l | tr -d ' '); \
	test "$$lines" = "3"


define define-constants-newline-multiple-lines
line1
line2
line3
line4
line5
endef

test-constants-newline-multiple-lines:
	$(call bowerbird::test::compare-strings,\
		$(words $(subst $(bowerbird::test::NEWLINE), ,$(define-constants-newline-multiple-lines))),\
		5)


test-constants-newline-single-line:
	$(call bowerbird::test::compare-strings,\
		$(words $(subst $(bowerbird::test::NEWLINE), ,single)),\
		1)
