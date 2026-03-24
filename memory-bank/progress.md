# Progress — rigor-cli

## Overall Status

**v0.1.0 IN PROGRESS** — PR #1 open (`feat/init`); CI green; Copilot findings addressed.

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

---

## What Is Pending

### v0.1.0 — IN PROGRESS

- [ ] PR #1 merged to main
- [ ] Tagged v0.1.0 + GitHub release created
- [ ] lib-foundation `.clinerules` upstream fix (`_detect_platform` values) — track in lib-foundation `feat/v0.3.10`

### Future

- [ ] Gist 1 install script — `docs/gists/gist-01-agent-rigor/` (k3d-manager)
- [ ] `mapfile` bash 3.2 compat fix in `bin/rigor` `_rigor_shellcheck` (v0.1.1)

---

## Known Constraints

| Item | Notes |
|---|---|
| `scripts/lib/foundation/` | Read-only git subtree — never edit directly |
| bash 3.2 compat | `mapfile` in `_rigor_shellcheck` requires bash 4+ — acceptable for v0.1.0 (CI on Ubuntu) |
| Symlinks in subtree | `scripts/lib/foundation/system.sh` + `agent_rigor.sh` are symlinks into deep subtree path — functional, tech debt |
