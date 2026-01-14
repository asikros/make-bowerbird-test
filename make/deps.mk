# Constants
WORKDIR_DEPS ?= $(error ERROR: Undefined variable WORKDIR_DEPS)

# Load Bowerbird Dependency Tools
BOWERBIRD_DEPS.MK := $(WORKDIR_DEPS)/bowerbird-deps/bowerbird_deps.mk
$(BOWERBIRD_DEPS.MK):
	@curl --silent --show-error --fail --create-dirs -o $@ -L \
https://raw.githubusercontent.com/asikros/make-bowerbird-deps/\
main/src/bowerbird-deps/bowerbird-deps.mk
include $(BOWERBIRD_DEPS.MK)


# Load Dependencies
$(call bowerbird::git-dependency, \
	name=bowerbird-help, \
	path=$(WORKDIR_DEPS)/bowerbird-help, \
	url=https://github.com/asikros/make-bowerbird-help.git, \
	branch=main, \
	entry=bowerbird.mk)

$(call bowerbird::git-dependency, \
	name=bowerbird-githooks, \
	path=$(WORKDIR_DEPS)/bowerbird-githooks, \
	url=https://github.com/asikros/make-bowerbird-githooks.git, \
	branch=main, \
	entry=bowerbird.mk)
