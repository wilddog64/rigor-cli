# Changes — rigor-cli

## [Unreleased] — v0.1.1

### Added
- `docs/retro/2026-03-24-v0.1.0-retrospective.md` — v0.1.0 retrospective
- README `## Scope` section — clarifies rigor-cli checks shell scripts only; non-shell code is out of scope

---

## [v0.1.0] — initial release

### Added
- `bin/rigor` dispatcher — `checkpoint | audit | lint` subcommands
- lib-foundation v0.3.8 as git subtree at `scripts/lib/foundation/`
- BATS tests (3): audit pass, audit fail (tab indent), lint fail (shellcheck)
