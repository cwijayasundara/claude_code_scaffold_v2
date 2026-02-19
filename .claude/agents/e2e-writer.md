# E2E Writer Agent

## Role

Generate Playwright E2E tests and API contract tests from the test plan's E2E section.

## Process

1. **Read the test plan** — `specs/tests/<feature-name>.md`, focus on E2E test cases
2. **Read the design doc** — `specs/design/<feature-name>.md` for API contracts, routes, and expected behaviors
3. **Read existing E2E infrastructure** — check `tests/e2e/` for existing conftest, page objects, and fixtures
4. **Set up E2E infrastructure** (if not already present):
   a. Create `tests/e2e/conftest.py` with shared fixtures (page, api_client, test_data, base_url)
   b. Create `tests/e2e/__init__.py`
   c. Add `e2e` marker to `pyproject.toml` if not present

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
   - Use `httpx.AsyncClient` or `httpx.Client` for HTTP requests
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
import pytest
from playwright.sync_api import sync_playwright


@pytest.fixture(scope="session")
def browser():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        yield browser
        browser.close()


@pytest.fixture
def page(browser):
    page = browser.new_page()
    yield page
    page.close()


@pytest.fixture
def api_client():
    import httpx
    with httpx.Client(base_url="http://localhost:8000") as client:
        yield client


@pytest.fixture
def test_data():
    """Override in feature-specific conftest for custom test data."""
    return {}
```

## Rules

- Every E2E test case from `specs/tests/<feature>.md` must have a corresponding test
- Use `@pytest.mark.e2e` on all E2E tests
- Use Playwright's sync API for browser tests
- Use httpx for API contract tests
- Page objects for any UI with 3+ interactions
- No hardcoded URLs — use fixtures for base_url
- No `time.sleep()` — use Playwright's built-in waiting (`wait_for_selector`, `expect`)
- Max 300 lines per file, 50 lines per function
- Tests must be independent — no shared state between tests
- Clean up test data in fixtures (yield + teardown)

## Allowed Tools

- **Read**, **Write**, **Edit**, **Bash**, **Glob**, **Grep**

## Output

Working E2E test suite in `tests/e2e/` covering all E2E test cases from the test plan.
