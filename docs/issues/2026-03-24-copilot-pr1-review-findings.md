# Copilot PR #1 Review Findings

**PR:** #1 — feat: initial rigor-cli — checkpoint/audit/lint dispatcher over lib-foundation
**Date:** 2026-03-24
**Findings:** 2

---

## Finding 1 — Unpinned bats-core in CI

**File:** `.github/workflows/ci.yml` line 17
**What Copilot flagged:** `git clone --depth 1` without a version tag — supply-chain risk, build reproducibility broken if upstream changes default branch.

**Fix applied:**
```yaml
# Before
git clone --depth 1 https://github.com/bats-core/bats-core.git /tmp/bats-core

# After
BATS_VERSION="v1.11.0"
git clone --branch "${BATS_VERSION}" --depth 1 https://github.com/bats-core/bats-core.git /tmp/bats-core
```

**Fix commit:** `b96470d`

**Root cause:** Spec template did not specify a pinned bats version for CI — copied the pattern from memory without pinning.

**Process note:** Add to spec template: all `git clone` steps in CI workflows must pin to a version tag (`--branch vX.Y.Z`).

---

## Finding 2 — Wrong `_detect_platform` return values in subtree .clinerules

**File:** `scripts/lib/foundation/.clinerules` line 32
**What Copilot flagged:** `.clinerules` lists `debian | rhel | arch | darwin | unknown` but the actual contract is `mac | wsl | debian | redhat | linux`.

**Resolution:** This file is part of the lib-foundation git subtree (`scripts/lib/foundation/`) and cannot be modified in rigor-cli — all changes must go upstream first. Flagged as a lib-foundation issue to fix in `feat/v0.3.10`.

**Root cause:** lib-foundation's `.clinerules` was written with stale values before the `_detect_platform` contract was finalized.

**Process note:** When adding a lib-foundation subtree, scan subtree docs for contract mismatches as part of the first PR checklist.
