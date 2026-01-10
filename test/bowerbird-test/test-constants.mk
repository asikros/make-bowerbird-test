test-constants-comma-defined:
	@test -n "$(BOWERBIRD_TEST_COMMA)"


test-constants-comma-value:
	@test "$(BOWERBIRD_TEST_COMMA)" = ","


test-constants-comma-in-subst:
	$(call bowerbird::test::compare-strings,$(subst $(BOWERBIRD_TEST_COMMA), ,a$(BOWERBIRD_TEST_COMMA)b$(BOWERBIRD_TEST_COMMA)c),a b c)


test-constants-comma-multiple-subst:
	$(call bowerbird::test::compare-strings,\
		$(subst $(BOWERBIRD_TEST_COMMA),,1$(BOWERBIRD_TEST_COMMA)2$(BOWERBIRD_TEST_COMMA)3$(BOWERBIRD_TEST_COMMA)4),\
		1234)


test-constants-comma-as-separator:
	$(call bowerbird::test::compare-sets,\
		$(subst $(BOWERBIRD_TEST_COMMA), ,alpha$(BOWERBIRD_TEST_COMMA)beta$(BOWERBIRD_TEST_COMMA)gamma),\
		alpha beta gamma)


define define-constants-newline-in-subst
line1
line2
line3
endef

test-constants-newline-defined:
	$(call bowerbird::test::compare-strings,\
		$(words $(subst $(BOWERBIRD_TEST_NEWLINE), ,$(define-constants-newline-in-subst))),\
		3)


test-constants-newline-multiline:
	@result=$$(printf '%b' '$(subst $(BOWERBIRD_TEST_NEWLINE),\n,$(define-constants-newline-in-subst))'); \
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
		$(words $(subst $(BOWERBIRD_TEST_NEWLINE), ,$(define-constants-newline-multiple-lines))),\
		5)


test-constants-newline-single-line:
	$(call bowerbird::test::compare-strings,\
		$(words $(subst $(BOWERBIRD_TEST_NEWLINE), ,single)),\
		1)
