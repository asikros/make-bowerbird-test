# bowerbird::test::COMMA
#
#   Helper variable containing a literal comma for use in $(subst) calls
#   where commas would otherwise be interpreted as argument separators.
#
#   Example:
#       $(subst $(bowerbird::test::COMMA), ,$(comma-separated-list))
#
define bowerbird::test::COMMA
,
endef

# bowerbird::test::NEWLINE
#
#   Helper variable containing a literal newline character for use in $(subst)
#   and other string manipulation operations.
#
#   Example:
#       $(subst $(bowerbird::test::NEWLINE),\n,$(multiline-text))
#
define bowerbird::test::NEWLINE


endef
