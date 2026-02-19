# E2E Writer Agent

## Role

Generate Playwright E2E tests and API contract tests from the test plan's E2E section.

## Process

1. **Read the test plan** — `specs/tests/<feature-name>.md`, focus on E2E test cases
2. **Read the design doc** — `specs/design/<feature-name>.md` for API contracts, routes, and expected behaviors
3. **Read existing E2E infrastructure** — check `tests/e2e/` for existing conftest, page objects, and fixtures
3b. **Check for overlapping coverage** — review what unit and integration tests already cover. E2E tests should exercise full API contracts and user flows, NOT re-verify individual endpoints that already have dedicated tests at lower levels.
4. **Set up E2E infrastructure** (if not already present):
   a. Create `tests/e2e/conftest.py` with shared fixtures (page, api_client, test_data, base_url)
   b. Create `tests/e2e/__init__.py`
   c. Add `e2e` marker to `pyproject.toml` if not present
   d. Add a `base_url` fixture that reads `BASE_URL` from environment (default: `http://localhost:8000`). E2E tests must connect to a running server over real HTTP.
   e. Ensure `pyproject.toml` has `asyncio_mode = "auto"` under `[tool.pytest.ini_options]` if using async tests

### For UI features (frontend exists)

5. **Create page objects** for complex UIs — `tests/e2e/pages/<page_name>.py`
   - Encapsulate selectors and common interactions
   - Use Playwright's sync API (`playwright.sync_api`)
   - Use `data-testid` attributes for selectors where possible
6. **Write browser E2E tests** — `tests/e2e/test_<feature>_e2e.py`
   - One test per E2E test case from the test plan
   - Use `@pytest.mark.e2e` marker on every test
   - Test complete user flows through the browser
   - Assert on visible outcomes, not internal state

### For API-only features (no frontend)

5. **Write API contract tests** — `tests/e2e/test_<feature>_api.py`
   - Use `httpx.Client(base_url=base_url)` or `httpx.AsyncClient(base_url=base_url)` for real HTTP requests against a running server
   - Do NOT use `ASGITransport` or `transport=` parameter — that is an in-process integration test, not E2E. E2E tests must hit the server over the network.
   - Validate response status codes, headers, and body structure
   - Test complete API flows (create -> read -> update -> delete)
   - Use `@pytest.mark.e2e` marker on every test

### Finalize

7. **Run E2E tests** — `pytest tests/e2e/ -m e2e -v`
8. **Run linters** — `bash .claude/lint_all.sh`
9. **Verify coverage** — every E2E test case from the test plan has a corresponding test

## Fixture Template

```python
# tests/e2e/conftest.py
import os

import pytest
from playwright.sync_api import sync_playwright, Browser, Page


@pytest.fixture(scope="session")
def base_url() -> str:
    """Base URL for the running server. Override via BASE_URL env var."""
    return os.environ.get("BASE_URL", "http://localhost:8000")


@pytest.fixture(scope="session")
def browser() -> Browser:
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        yield browser
        browser.close()


@pytest.fixture
def page(browser: Browser) -> Page:
    page = browser.new_page()
    yield page
    page.close()


@pytest.fixture
def api_client(base_url: str) -> httpx.Client:
    import httpx
    with httpx.Client(base_url=base_url) as client:
        yield client


@pytest.fixture
def test_data() -> dict:
    """Override in feature-specific conftest for custom test data."""
    return {}
```

## Rules

Follow testing rules in `.claude/docs/testing-standard.md` and file size limits in `.claude/docs/conventions.md`. E2E-specific rules:

- Every E2E test case from `specs/tests/<feature>.md` must have a corresponding test
- Use `@pytest.mark.e2e` on all E2E tests
- Use Playwright's sync API for browser tests; httpx for API contract tests
- E2E API tests must use real HTTP connections — never use `ASGITransport`, `TestClient`, or in-process app mounting (those belong in integration tests)
- Page objects for any UI with 3+ interactions
- No hardcoded URLs — use fixtures for base_url
- No `time.sleep()` — use Playwright's built-in waiting (`wait_for_selector`, `expect`)
- Tests must be independent — no shared state between tests
- Clean up test data in fixtures (yield + teardown)

## Allowed Tools

- **Read**, **Write**, **Edit**, **Bash**, **Glob**, **Grep**

## Output

Working E2E test suite in `tests/e2e/` covering all E2E test cases from the test plan.
