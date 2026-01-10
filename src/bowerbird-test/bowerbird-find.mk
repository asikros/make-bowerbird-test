# bowerbird::test::find-cached-test-results, path, result
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
#		Throws an error if result empty.
#
#   Example:
#		$$(call bowerbird::test::find-cached-test-results,path,result)
#
define bowerbird::test::find-cached-test-results # path, result
$$(if $1,,$$(error ERROR: bowerbird::test::find-cached-test-results, no path specified)) \
$$(if $2,,$$(error ERROR: bowerbird::test::find-cached-test-results, no result specified)) \
$$(foreach f,\
    $$(shell test -d $1 && find $$(strip $1) -type f -name '*.$$(strip $2)'),\
    $$(patsubst $$(abspath $$(strip $1))/%.$$(strip $2),%,$$f))
endef


# bowerbird::test::find-cached-test-results-failed, path
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
#		$$(call bowerbird::test::find-cached-test-results-failed,path)
#
define bowerbird::test::find-cached-test-results-failed # path
$$(if $1,,$$(error ERROR: bowerbird::test::find-cached-test-results-failed, no path specified)) \
$(call bowerbird::test::find-cached-test-results,$1,$$(bowerbird-test.constant.ext-fail))
endef


# bowerbird::test::find-test-files, path, pattern
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
define bowerbird::test::find-test-files # path, pattern
$(shell test -d $1 && find $(abspath $1) -type f -name '$2' 2>/dev/null)
endef


# bowerbird::test::find-test-targets, files, patterns
#
#   Discovers test targets from both explicit target definitions and add-mock-test calls.
#   Handles line continuation (backslash) for multi-line target definitions.
#   Filters discovered targets by the provided patterns (supports multiple patterns).
#
#   Args:
#       files: List of files to search for make targets.
#       patterns: Space-separated list of shell-style patterns (e.g., "test*" or "test* check*").
#
#   Example:
#       $(call bowerbird::test::find-test-targets,test-file-1.mk test-file-2.mk,test*)
#       $(call bowerbird::test::find-test-targets,test-file-1.mk,test* check*)
#
define bowerbird::test::find-test-targets # files, patterns
$(sort $(filter \
    $(subst *,%,$2),\
    $(shell cat $1 | \
        sed -e ':a' -e '/\\$$/N' -e 's/\\\n//g' -e 'ta' | \
        sed -n \
            -e 's/^\([a-zA-Z0-9_-][a-zA-Z0-9_-]*\):.*/\1/p' \
            -e 's/^.*bowerbird::test::add-mock-test$(call bowerbird::test::COMMA)[ 	]*\([a-zA-Z0-9_-][a-zA-Z0-9_-]*\).*/\1/p' \
        2>/dev/null)))
endef
