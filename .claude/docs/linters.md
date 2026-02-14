# Custom Linters Reference

Run all: `bash .claude/lint_all.sh`

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

## 2. structured_logging

**Purpose**: No raw `print()` or `console.log()` in production code.

**Checks**: `.py` files for `print(`, `.ts/.tsx/.js/.jsx` for `console.log/error/warn`.

**Exempt**: Test files, `__main__.py`.

**Fix**: Replace with `logger.info()`, `logger.debug()`, etc.

---

## 3. naming_conventions

**Purpose**: Enforce `snake_case` for files/functions, `PascalCase` for classes.

**Checks**: Python filenames, `def` declarations, `class` declarations. TS/JS filenames (no PascalCase).

**Exempt**: `__init__.py`, `__main__.py`, `conftest.py`, test files.

**Fix**: Rename to match convention.

---

## 4. file_size

**Purpose**: Keep files and functions small.

**Checks**: Max 300 lines per file (warn at 250), max 50 lines per function.

**Fix**: Split large files into focused modules. Extract helper functions.

---

## 5. spec_coverage

**Purpose**: Every service module must trace to a spec.

**Checks**: Each `.py` in `src/service/` (except `__init__.py`) must have a matching file in `specs/features/`.

**Fix**: Create `specs/features/<module-name>.md` using the feature spec template.
