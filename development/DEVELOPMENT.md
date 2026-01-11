# Developer Guide

Quick reference for contributing to make-bowerbird-test.

## Code Standards

Follow the project's coding conventions:
- **[Make Style Guide](https://github.com/asikros/make-bowerbird-docs/blob/main/requirements/make-styleguide.md)** - Naming conventions, documentation patterns, and formatting rules for Makefiles

## Development Workflows

- **[Testing Workflow](https://github.com/asikros/make-bowerbird-docs/blob/main/workflows/testing.md)** - How to test changes, debug failures, and ensure test coverage

## Key Principles

1. **Test everything**: Run `make clean && make check` after any modifications
2. **Root cause failures**: Fix underlying issues, don't hack tests or code to pass
3. **Simple, direct tests**: Test failures should clearly indicate what's broken
4. **Add missing coverage**: If a bug wasn't caught, add a test for it

## Quick Start

```bash
# Run all tests
make check

# Clean build artifacts and run tests
make clean && make check

# Run a specific test
make test-<name>
```

---

## Directory Structure

```
development/
├── proposals/      # Design documents and feature specifications
│   ├── draft/      # Proposals under active development
│   ├── accepted/   # Proposals accepted and implemented
│   ├── rejected/   # Proposals that were rejected (with rationale)
│   └── PROPOSALS.md # Proposal lifecycle and format guidelines
└── DEVELOPMENT.md  # This file
```

**Note**: Code standards and workflow documentation have been moved to the [make-bowerbird-docs](https://github.com/asikros/make-bowerbird-docs) repository.

## Proposals

For information about creating and managing proposals, see **[proposals/PROPOSALS.md](proposals/PROPOSALS.md)**.

This includes:
- Proposal lifecycle (Draft → Accepted/Rejected)
- Required proposal format and headers
- List of current proposals by status
