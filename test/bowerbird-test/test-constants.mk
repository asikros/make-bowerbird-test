test-constants-comma-defined:
	@test -n "$(BOWERBIRD_COMMA)"


test-constants-comma-value:
	@test "$(BOWERBIRD_COMMA)" = ","


test-constants-comma-in-subst:
	$(call bowerbird::test::compare-strings,$(subst $(BOWERBIRD_COMMA), ,a$(BOWERBIRD_COMMA)b$(BOWERBIRD_COMMA)c),a b c)



define define-constants-newline-in-subst
line1
line2
line3
endef

test-constants-newline-in-subst:
	$(call bowerbird::test::compare-strings,\
		$(words $(subst $(BOWERBIRD_NEWLINE), ,$(define-constants-newline-in-subst))),\
		3)

