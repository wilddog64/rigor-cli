# Progress — rigor-cli

## Overall Status

**v0.1.0 SHIPPED** — PR #1 merged (`f720184`), tagged v0.1.0, GitHub release created 2026-03-24.
**v0.1.1 ACTIVE** — PR #3 merged (`f304c14`) 2026-03-24; lib-foundation subtree pulled (`c5662c9`); symlink tech debt resolved (`c283d48`).

---

## What Is Complete

- [x] GitHub repo created (`wilddog64/rigor-cli`)
- [x] lib-foundation v0.3.8 subtree added at `scripts/lib/foundation/`
- [x] `bin/rigor` dispatcher — `checkpoint | audit | lint`
- [x] BATS test suite — 3 tests (audit pass, audit fail tab-indent, lint fail shellcheck)
- [x] GitHub Actions CI — shellcheck + BATS; bats-core pinned to v1.11.0
- [x] Apache 2.0 LICENSE
- [x] README in k3d-manager format — quick start, what it checks, key contracts, CI integration
- [x] `.github/copilot-instructions.md`
- [x] `.clinerules` (repo root)
- [x] `memory-bank/` initialized
- [x] Branch protection on `main` — required status checks + enforce_admins + 1 approving review
- [x] Copilot PR #1 findings addressed (b96470d): bats-core pinned; .clinerules subtree issue flagged upstream
- [x] Issue doc: `docs/issues/2026-03-24-copilot-pr1-review-findings.md`
- [x] PR #2 merged (`e302af4f`) — README Scope section, v0.1.0 retro, Copilot PR#2 findings fixed; enforce_admins restored
- [x] mapfile compat fix (`8ae57bc`) — `while IFS= read -r` in `_rigor_shellcheck`
- [x] Gist-01 install script (`310fd16`) — `docs/gists/gist-01-agent-rigor/install.sh`
- [x] PR #3 merged (`f304c14`) — mapfile compat + gist-01; Copilot 4 findings fixed; enforce_admins restored
- [x] lib-foundation subtree pull (`c5662c9`) — `.clinerules` fix lands in subtree
- [x] Symlink tech debt resolved (`c283d48`) — `_RIGOR_LIB_DIR` updated to real path `scripts/lib/foundation/scripts/lib`

---

## What Is Pending

### v0.1.1 — ACTIVE (on feat/v0.1.1)

- [x] Publish gist — https://gist.github.com/wilddog64/81c767a0560e39c8d6e0f8bd9706973b

---

## Known Constraints

| Item | Notes |
|---|---|
| `scripts/lib/foundation/` | Read-only git subtree — never edit directly |
