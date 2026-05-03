# Progress — rigor-cli

## Overall Status

**v0.1.0 SHIPPED** — PR #1 merged (`f720184`), tagged v0.1.0, GitHub release created 2026-03-24.
**v0.1.1 SHIPPED** — PR #4 merged (`c5bda1e`), tagged v0.1.1, GitHub release created 2026-03-25. `enforce_admins` restored.
**v0.1.2 SHIPPED** — PR #5 merged (`5ed7f8d`), tagged v0.1.2, GitHub release created 2026-03-25. `enforce_admins` restored.
**v0.1.3 SHIPPED** — PR #6 merged (`675f6e9`), tagged `306cd86`, GitHub release created 2026-05-03. `enforce_admins` restored.
**v0.1.4 SHIPPED** — PR #7 merged (`ac7a39d`), GitHub release created 2026-05-03. `rigor lint` now dispatches per-extension via `RIGOR_LINT_BACKENDS`.

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
- [x] Copilot PR #1 findings addressed (`b96470d`): bats-core pinned; .clinerules subtree issue flagged upstream
- [x] Issue doc: `docs/issues/2026-03-24-copilot-pr1-review-findings.md`
- [x] PR #2 merged (`e302af4f`) — README Scope section, v0.1.0 retro, Copilot PR#2 findings fixed; enforce_admins restored
- [x] mapfile compat fix (`8ae57bc`) — `while IFS= read -r` in `_rigor_shellcheck`
- [x] Gist-01 install script (`310fd16`) — `docs/gists/gist-01-agent-rigor/install.sh`
- [x] PR #3 merged (`f304c14`) — mapfile compat + gist-01; Copilot 4 findings fixed; enforce_admins restored
- [x] lib-foundation subtree pull (`c5662c9`) — `.clinerules` fix lands in subtree
- [x] Symlink tech debt resolved (`c283d48`) — `_RIGOR_LIB_DIR` updated to real path `scripts/lib/foundation/scripts/lib`
- [x] Gist published — https://gist.github.com/wilddog64/81c767a0560e39c8d6e0f8bd9706973b
- [x] PR #4 merged (`c5bda1e`) — v0.1.1 milestone close-out; how-to install doc; Copilot 2 findings fixed
- [x] v0.1.1 tagged + GitHub release created — 2026-03-25
- [x] Retro: `docs/retro/2026-03-25-v0.1.1-retrospective.md`
- [x] v0.1.3 rigor review — subtree pull `afc72a5`; feature commit `66c507d`; `rigor review` dispatches to `_ai_agent_review`
- [x] README refresh — docs updated to include `rigor review`, the AI review backend contract, and the v0.1.3 release entry
- [x] PR #6 merged (`675f6e9`) — rigor review subcommand; lib-foundation v0.3.20 subtree; Copilot 4 findings fixed
- [x] v0.1.3 tagged `306cd86`, GitHub release created 2026-05-03
- [x] Retro: `docs/retro/2026-05-03-v0.1.3-retrospective.md`

---

## What Is Pending

### Next Work

- `rigor-cli-v0.1.5` branch will carry post-release cleanup and pyjenkinsapi subtree integration.

---

## Known Constraints

| Item | Notes |
|---|---|
| `scripts/lib/foundation/` | Read-only git subtree — never edit directly |
