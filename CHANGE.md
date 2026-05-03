# Changes — rigor-cli

## [v0.1.4] — 2026-05-03

### Added
- `bin/rigor`: `_rigor_lint` replaces `_rigor_shellcheck` — dispatches per-extension via `RIGOR_LINT_BACKENDS` (space-separated `ext:command` pairs, default: `sh:shellcheck`); missing backends warn and skip; returns non-zero if any backend fails
- `scripts/tests/rigor.bats`: 3 new tests — RIGOR_LINT_BACKENDS dispatch, missing backend warning, explicit file extension filtering (6 total)
- README: updated Scope section, lint docs, and `RIGOR_LINT_BACKENDS` env var table
- `.github/copilot-instructions.md`: updated lint description to reference `RIGOR_LINT_BACKENDS`

---

## [v0.1.3] — 2026-05-03

### Added
- `bin/rigor`: `review` subcommand — `_rigor_review` wraps `_ai_agent_review`; warns when `.github/copilot-instructions.md` is absent; dispatches to backend selected by `AI_REVIEW_FUNC` (default: `copilot`) with model from `AI_REVIEW_MODEL` (default: `gpt-5.4-mini`)
- `scripts/lib/foundation/`: subtree pulled to lib-foundation v0.3.20 — `_ai_agent_review` dispatch wrapper, `_copilot_review` deny-tool fix, `_copilot_auth_check` gate removal, `_agent_lint` BATS coverage for `.js`/`.md` globs, stale `K3DM_ENABLE_AI` doc references removed

---

## [v0.1.2] — 2026-03-25

### Changed
- `scripts/lib/foundation/`: subtree pulled to lib-foundation v0.3.11 — `_agent_audit` now checks staged `.yaml`/`.yml` files for hardcoded IPv4 addresses and warns to use CoreDNS hostnames

---

## [v0.1.1] — 2026-03-25

### Added
- `docs/retro/2026-03-24-v0.1.0-retrospective.md` — v0.1.0 retrospective
- README `## Scope` section — clarifies rigor-cli checks shell scripts only; non-shell code is out of scope
- `docs/gists/gist-01-agent-rigor/install.sh` — one-command install script (https://gist.github.com/wilddog64/81c767a0560e39c8d6e0f8bd9706973b)

### Fixed
- `bin/rigor`: replace `mapfile` with `while IFS= read -r` in `_rigor_shellcheck` — bash 3.2 compat
- `bin/rigor`: update `_RIGOR_LIB_DIR` to real subtree path `scripts/lib/foundation/scripts/lib` — removes symlink workaround

---

## [v0.1.0] — 2026-03-24

### Added
- `bin/rigor` dispatcher — `checkpoint | audit | lint` subcommands
- lib-foundation v0.3.8 as git subtree at `scripts/lib/foundation/`
- BATS tests (3): audit pass, audit fail (tab indent), lint fail (shellcheck)
