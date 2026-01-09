# BOWERBIRD_COMMA
#
#   Helper variable containing a literal comma for use in $(subst) calls
#   where commas would otherwise be interpreted as argument separators.
#
#   Example:
#       $(subst $(BOWERBIRD_COMMA), ,$(comma-separated-list))
#
BOWERBIRD_COMMA := ,

# BOWERBIRD_NEWLINE
#
#   Helper variable containing a literal newline character for use in $(subst)
#   and other string manipulation operations.
#
#   Example:
#       $(subst $(BOWERBIRD_NEWLINE),\n,$(multiline-text))
#
define BOWERBIRD_NEWLINE


endef
