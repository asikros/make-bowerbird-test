test-constants-comma-defined:
	@test -n "$(BOWERBIRD_COMMA)"
	@test "$(BOWERBIRD_COMMA)" = ","


test-constants-comma-in-subst:
	$(call bowerbird::test::compare-strings,$(subst $(BOWERBIRD_COMMA), ,a$(BOWERBIRD_COMMA)b$(BOWERBIRD_COMMA)c),a b c)


test-constants-comma-empty-split:
	$(call bowerbird::test::compare-strings,$(subst $(BOWERBIRD_COMMA),|,a$(BOWERBIRD_COMMA)$(BOWERBIRD_COMMA)b),a||b)


test-constants-newline-defined:
	@echo '$(BOWERBIRD_NEWLINE)' | od -An -tx1 | grep -q '0a'


define test-multiline-content
line1
line2
line3
endef

test-constants-newline-in-subst:
	$(call bowerbird::test::compare-strings,\
		$(words $(subst $(BOWERBIRD_NEWLINE), ,$(test-multiline-content))),\
		3)


define test-expected-output
first line
second line
third line
endef

test-constants-newline-with-printf:
	@mkdir -p $(WORKDIR_TEST)/test-constants-newline-with-printf
	@printf '%b' '$(subst $(BOWERBIRD_NEWLINE),\n,$(test-expected-output))' > $(WORKDIR_TEST)/test-constants-newline-with-printf/expected.txt
	@test "$$(wc -l < $(WORKDIR_TEST)/test-constants-newline-with-printf/expected.txt)" = "3"
	@printf 'first line\nsecond line\nthird line' > $(WORKDIR_TEST)/test-constants-newline-with-printf/expected-compare.txt
	@diff -q $(WORKDIR_TEST)/test-constants-newline-with-printf/expected.txt $(WORKDIR_TEST)/test-constants-newline-with-printf/expected-compare.txt


define test-five-lines
1
2
3
4
5
endef

test-constants-newline-count:
	@echo '$(test-five-lines)' | grep -c '^' | grep -q '^5$$'


define test-csv-content
a,b,c
d,e,f
endef

test-constants-comma-and-newline-together:
	$(call bowerbird::test::compare-strings,\
		$(words $(subst $(BOWERBIRD_NEWLINE), ,$(subst $(BOWERBIRD_COMMA), ,$(test-csv-content)))),\
		6)
