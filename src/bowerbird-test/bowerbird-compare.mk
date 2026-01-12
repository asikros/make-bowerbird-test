# bowerbird::test::compare-file-content-from-var, file, varname
#
#   Compares file contents against expected value stored in a variable.
#   This variant takes a variable NAME (not value) to work around Make's
#   limitation with multiline content in $(call ...) inside $(eval ...).
#
#   Args:
#       file: Path to file containing actual output.
#       varname: Name of variable containing expected content (without $()).
#
#   Errors:
#       Exits with non-zero code if file not found or content mismatch.
#
#   Example:
#       define expected-output
#       line1
#       line2
#       endef
#
#       test:
#           $(call bowerbird::test::compare-file-content-from-var,results.log,expected-output)
#
define bowerbird::test::compare-file-content-from-var # file, varname
printf '%b\n' '$(subst $(bowerbird::test::NEWLINE),\n,$(value $2))' | diff -q "$1" - >/dev/null || \
	(>&2 echo "ERROR: Content mismatch for $1" && \
	 >&2 echo "Expected:" && \
	 >&2 printf '%b\n' '$(subst $(bowerbird::test::NEWLINE),\n,$(value $2))' && \
	 >&2 echo "Actual:" && \
	 >&2 cat "$1" && \
	 exit 1)
endef


# bowerbird::test::compare-files, file1, file2
#
#   Compares the content of the two files.
#
#   Args:
#       file1: First file to be compared.
#       file2: Second file to be compared.
#
#   Errors:
#       Terminates with exit 1 if the files are different.
#
#   Example:
#       $(call bowerbird::test::compare-files,./file1,./file2)
#
define bowerbird::test::compare-files # file1, file2
    diff -q $1 $2 || \
            (echo "ERROR: Failed file comparison:" 1>&2 && diff -y $1 $2 1>&2 && exit 1)
endef


# bowerbird::test::compare-sets, set1, set2
#
#   Compares two unordered space-separated lists of values. Duplicate elements are not
#   considered.
#
#   Args:
#       set1: First set to be compared.
#       set2: Second set to be compared.
#
#   Errors:
#       Terminates with exit 1 if the lists contain different elements.
#
#   Example:
#       $(call bowerbird::test::compare-sets,equal-1 equal-2,equal-2 equal-1)
#       ! $(call bowerbird::test::compare-sets,not-equal-1,not-equal-1 not-equal-2)
define bowerbird::test::compare-sets # set1, set2
    test "$(sort $1)" = "$(sort $2)" || \
            (echo "ERROR: Failed list comparison: '$(sort $1)' != '$(sort $2)'" >&2 && \
            exit 1)
endef


# bowerbird::test::compare-strings, str1, str2
#
#   Compares two string values.
#
#   Args:
#       str1: First string to be compared.
#       str2: Second string to be compared.
#
#   Errors:
#       Terminates with exit 1 if strings are not equal.
#
#   Example:
#       $(call bowerbird::test::compare-strings,equal,equal)
#       ! $(call bowerbird::test::compare-strings,not-equal,not equal)
#
define bowerbird::test::compare-strings # str1, str2
    test "$1" = "$2" || \
            (echo "ERROR: Failed string comparison: '$1' != '$2'" >&2 && exit 1)
endef
