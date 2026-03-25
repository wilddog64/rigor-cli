# Changes — rigor-cli

## [Unreleased] — v0.1.1

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
