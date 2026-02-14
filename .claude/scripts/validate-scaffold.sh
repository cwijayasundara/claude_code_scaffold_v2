#!/bin/bash
# Validate the Claude Code Production Scaffold v2 structure.
# Usage: bash .claude/scripts/validate-scaffold.sh

PASS=0
FAIL=0
WARN=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }
warn() { echo "  WARN: $1"; WARN=$((WARN + 1)); }

echo "=== Claude Code Scaffold v2 Validation ==="
echo ""

# ---- 1. Core files ----
echo "1. Core files"
for f in CLAUDE.md README.md Makefile pyproject.toml requirements.txt requirements-dev.txt Dockerfile .gitignore .env.example .mcp.json .dockerignore; do
  if [[ -f "$f" ]]; then pass "$f exists"; else fail "$f missing"; fi
done
echo ""

# ---- 2. CLAUDE.md structure ----
echo "2. CLAUDE.md"
if [[ -f "CLAUDE.md" ]]; then
  LINE_COUNT=$(wc -l < CLAUDE.md | tr -d ' ')
  if [[ "$LINE_COUNT" -le 90 ]]; then
    pass "CLAUDE.md is $LINE_COUNT lines (under 90)"
  else
    fail "CLAUDE.md is $LINE_COUNT lines (should be under 90)"
  fi
  if grep -q ".claude/docs/" CLAUDE.md; then pass "references .claude/docs/"; else fail "missing .claude/docs/ references"; fi
  if grep -q "Layer" CLAUDE.md; then pass "documents layer model"; else fail "missing layer model"; fi
  if grep -q "lint_all.sh" CLAUDE.md; then pass "references lint_all.sh"; else fail "missing lint_all.sh reference"; fi
fi
echo ""

# ---- 3. Layer directories ----
echo "3. Layer directories"
for layer in types config repo service runtime ui; do
  if [[ -d "src/$layer" && -f "src/$layer/__init__.py" ]]; then
    pass "src/$layer/"
  else
    fail "src/$layer/ missing or incomplete"
  fi
done
echo ""

# ---- 4. Hooks (3 expected) ----
echo "4. Hooks"
for hook in pre-write-check post-write-lint post-commit-spec-check; do
  if [[ -f ".claude/hooks/$hook.sh" && -x ".claude/hooks/$hook.sh" ]]; then
    pass "$hook.sh"
  else
    fail "$hook.sh missing or not executable"
  fi
done
HOOK_COUNT=$(ls .claude/hooks/*.sh 2>/dev/null | wc -l | tr -d ' ')
echo "  INFO: $HOOK_COUNT hook scripts found"
echo ""

# ---- 5. Agents (5 expected) ----
echo "5. Agents"
for agent in code-reviewer test-writer; do
  if [[ -f ".claude/agents/$agent.yaml" ]]; then pass "$agent agent"; else fail "$agent agent missing"; fi
done
for agent in spec-writer implementer refactorer; do
  if [[ -f ".claude/agents/$agent.md" ]]; then pass "$agent agent"; else fail "$agent agent missing"; fi
done
AGENT_COUNT=$(ls .claude/agents/ 2>/dev/null | wc -l | tr -d ' ')
echo "  INFO: $AGENT_COUNT agent files found"
echo ""

# ---- 6. Custom linters (5 expected) ----
echo "6. Custom linters"
for linter in layer_deps structured_logging naming_conventions file_size spec_coverage; do
  if [[ -f ".claude/linters/$linter.sh" && -x ".claude/linters/$linter.sh" ]]; then
    pass "$linter.sh"
  else
    fail "$linter.sh missing or not executable"
  fi
done
if [[ -f ".claude/lint_all.sh" && -x ".claude/lint_all.sh" ]]; then
  pass "lint_all.sh"
else
  fail "lint_all.sh missing or not executable"
fi
echo ""

# ---- 7. Spec system ----
echo "7. Spec system"
for tmpl in .claude/templates/app_spec_template.xml .claude/templates/feature_spec.md .claude/templates/design_doc.md .claude/templates/execution_plan.md; do
  if [[ -f "$tmpl" ]]; then pass "$tmpl"; else fail "$tmpl missing"; fi
done
if [[ -f ".claude/scripts/init-from-app-spec.sh" && -x ".claude/scripts/init-from-app-spec.sh" ]]; then
  pass "init-from-app-spec.sh"
else
  fail "init-from-app-spec.sh missing or not executable"
fi
echo ""

# ---- 8. Documentation (5 expected) ----
echo "8. Documentation"
for doc in architecture workflow conventions linters spec-system; do
  if [[ -f ".claude/docs/$doc.md" ]]; then pass ".claude/docs/$doc.md"; else fail ".claude/docs/$doc.md missing"; fi
done
echo ""

# ---- 9. Settings.json hook wiring ----
echo "9. Settings.json hook wiring"
if [[ -f ".claude/settings.json" ]]; then
  pass ".claude/settings.json exists"
  for hook_ref in pre-write-check post-write-lint post-commit-spec-check; do
    if grep -q "$hook_ref" .claude/settings.json; then
      pass "$hook_ref wired"
    else
      fail "$hook_ref NOT wired in settings.json"
    fi
  done
fi
echo ""

# ---- 10. CI pipeline ----
echo "10. CI pipeline"
if [[ -f ".github/workflows/ci.yml" ]]; then
  pass "ci.yml exists"
  if grep -q "lint_all.sh" .github/workflows/ci.yml; then pass "CI runs custom linters"; else fail "CI missing linters"; fi
fi
if [[ -f ".github/workflows/release.yml" ]]; then pass "release.yml exists"; fi
echo ""

# ---- Summary ----
echo "=== Summary ==="
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
echo "  WARN: $WARN"
echo ""
if [[ "$FAIL" -eq 0 ]]; then
  echo "Scaffold is correctly configured. All checks passed."
else
  echo "Scaffold has $FAIL issue(s) that need fixing. See FAIL items above."
  exit 1
fi
