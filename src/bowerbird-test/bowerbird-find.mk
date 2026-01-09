# bowerbird::test::find-test-files,<path>,<pattern>
#
#   Returns a list of all the files matching the specified pattern under the directory
#	tree starting with the specified path.
#
#   Args:
#       path: Starting directory name for the search.
#       pattern: Wildcard expression for matching filenames.
#
#   Example:
#       $(call bowerbird::test::find-test-files,test/,test*.*)
#
define bowerbird::test::find-test-files
$(shell test -d $1 && find $(abspath $1) -type f -name '$2' 2>/dev/null)
endef


# bowerbird::test::find-test-targets,<files>,<pattern>
#
#   Discovers tests from both explicit targets and add-mock-test calls.
#   Handles line continuation (backslash) for multi-line macro calls.
#
#   Args:
#       files: List of files to search for make targets.
#       pattern: Wildcard expression for matching filenames.
#
#   Example:
#       $(call bowerbird::test::find-test-targets,test-file-1.mk test-files-2.mk)
#
define bowerbird::test::find-test-targets
$(sort $(shell cat $1 | \
    sed -e ':a' -e '/\\$$/N' -e 's/\\\n//g' -e 'ta' | \
    sed -n \
        -e 's/\(^$(subst *,[^:]*,$(bowerbird-test.config.target-pattern-user))\):.*/\1/p' \
        -e 's/^.*bowerbird::test::add-mock-test$(BOWERBIRD_COMMA)[ 	]*\($(subst *,[^$(BOWERBIRD_COMMA)]*,$(bowerbird-test.config.target-pattern-user))\).*/\1/p' \
    2>/dev/null))
endef


# bowerbird::test::find-cached-test-results,<path>,<result>
#
#   Helper function for extracting the list of targets from cached tests matching the
#	specified result.
#
#   Args:
#       path: Path to the cached results directory.
#       result: The desired test result. Typically one of the following values from:
#			bowerbird-test.constant.ext-pass or bowerbird-test.constant.ext-fail.
#
#	Error:
#		Throws an error if path empty.
#		Throws an result if result empty.
#
#   Example:
#		$$(call bowerbird::test::find-cached-test-results,<path>,<result>)
#
define bowerbird::test::find-cached-test-results
$$(if $1,,$$(error ERROR: bowerbird::test::find-cached-test-results, no path specified)) \
$$(if $2,,$$(error ERROR: bowerbird::test::find-cached-test-results, no result specified)) \
$$(foreach f,\
    $$(shell test -d $1 && find $$(strip $1) -type f -name '*.$$(strip $2)'),\
    $$(patsubst $$(abspath $$(strip $1))/%.$$(strip $2),%,$$f))
endef


# bowerbird::test::find-failed-cached-test-results,<path>
#
#   Function for extracting the list of targets matching previously failed tests.
#
#   Args:
#       path: Path to the cached results directory.
#
#	Error:
#		Throws an error if path empty.
#
#   Example:
#		$$(call bowerbird::test::find-cached-test-results,<path>,<result>)
#
define bowerbird::test::find-failed-cached-test-results
$$(if $1,,$$(error ERROR: bowerbird::test::find-failed-cached-test-results, no path specified)) \
$(call bowerbird::test::find-cached-test-results,$1,$$(bowerbird-test.constant.ext-fail))
endef
