# Development Documentation

This directory contains development notes, proposals, and design documents for the make-bowerbird-test framework.

## Directory Structure

```
development/
├── proposals/
│   ├── draft/      # Proposals under active development
│   ├── accepted/   # Proposals accepted and implemented
│   └── rejected/   # Proposals that were rejected (with rationale)
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

```markdown
> **Status**: Draft | Accepted | Rejected
> **Project**: make-bowerbird-test
> **Created**: YYYY-MM-DD
> **Author**: Name or Team
```

## Current Proposals

### Draft
- `01-mock-shell-testing.md` - Mock shell framework for testing Make recipes without executing commands

### Accepted
_(None yet)_

### Rejected
_(None yet)_
