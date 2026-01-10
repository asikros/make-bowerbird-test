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
#		$(call bowerbird::test::find-cached-test-results-failed,path)
#
define bowerbird::test::find-cached-test-results-failed # path
$(if $1,,$(error ERROR: bowerbird::test::find-cached-test-results-failed, no path specified)) \
$(call bowerbird::test::__find-cached-test-results-impl,$1,$(bowerbird-test.constant.ext-fail))
endef


# bowerbird::test::find-test-files, paths, patterns
#
#   Returns a sorted list of all files matching the specified patterns under the
#   directory trees starting with the specified paths (supports multiple paths and patterns).
#
#   Args:
#       paths: Space-separated list of directory paths to search.
#       patterns: Space-separated list of shell-style patterns (e.g., "test*.mk" or "test*.mk check*.mk").
#
#   Example:
#       $(call bowerbird::test::find-test-files,test/,test*.mk)
#       $(call bowerbird::test::find-test-files,test/ src/,test*.mk check*.mk)
#
define bowerbird::test::find-test-files # paths, patterns
$(sort $(foreach path,$1,$(foreach pattern,$2,$(shell test -d $(path) && find $(abspath $(path)) -type f -name '$(pattern)' 2>/dev/null))))
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


# Private implementation: Helper for extracting cached test results by extension
define bowerbird::test::__find-cached-test-results-impl # path, result
$(if $1,,$(error ERROR: bowerbird::test::__find-cached-test-results-impl, no path specified)) \
$(if $2,,$(error ERROR: bowerbird::test::__find-cached-test-results-impl, no result specified)) \
$(foreach f,\
    $(shell test -d $1 && find $(abspath $(strip $1)) -type f -name '*.$(strip $2)' 2>/dev/null),\
    $(basename $(notdir $f)))
endef
