# Developer Guide

Quick reference for contributing to make-bowerbird-test.

## Code Standards

Follow the project's coding conventions:
- **[Make Style Guide](requirements/make-styleguide.md)** - Naming conventions, documentation patterns, and formatting rules for Makefiles

## Development Workflows

- **[Testing Workflow](workflows/testing.md)** - How to test changes, debug failures, and ensure test coverage

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
├── proposals/
│   ├── draft/      # Proposals under active development
│   ├── accepted/   # Proposals accepted and implemented
│   └── rejected/   # Proposals that were rejected (with rationale)
├── requirements/   # Code standards and style guides
├── workflows/      # Development process documentation
└── README.md       # This file
```

## Proposal Lifecycle

### 1. Draft
New proposals start in `proposals/draft/`. These are under active development and review.

**Status**: `Draft`

### 2. Accepted
Once a proposal is reviewed, approved, and implemented, it moves to `proposals/accepted/`.

**Status**: `Accepted`

### 3. Rejected
If a proposal is not accepted, it moves to `proposals/rejected/` with a rationale section explaining why.

**Status**: `Rejected`

## Proposal Format

All proposals must include this header:

````markdown
```
Status:   Draft | Accepted | Rejected
Project:  make-bowerbird-test
Created:  YYYY-MM-DD
Author:   Name or Team
```

---
````

## Current Proposals

### Draft
_(None yet)_

### Accepted
- `01-mock-shell-testing.md` - Mock shell framework for testing Make recipes without executing commands

### Rejected
_(None yet)_
