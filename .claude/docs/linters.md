# Custom Linters Reference

Run all: `python3 .claude/lint_all.py`

All linters exit 0 on success, 1 on failure. Error messages include remediation instructions.

---

## 1. layer_deps

**Purpose**: Enforce forward-only layer dependencies.

**Checks**: Python import statements. A file in layer N cannot import from layer N+1 or higher.

**Example violation**:
```
LAYER_DEPS: src/types/user.py:5 layer 'types' (0) imports 'service' (3).
  Remediation: Layer 'types' cannot import from 'service'. Move the dependency or refactor.
```

**Fix**: Move the import to the correct layer, or extract shared types.

---

## 2. file_size

**Purpose**: Keep files and functions small.

**Checks**: Max 300 lines per file (warn at 250), max 50 lines per function.

**Fix**: Split large files into focused modules. Extract helper functions.
