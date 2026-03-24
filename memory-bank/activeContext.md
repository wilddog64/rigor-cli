# Active Context — rigor-cli

## Current State: `feat/v0.1.1` (as of 2026-03-24)

**v0.1.0 SHIPPED** — PR #1 merged to main (`f720184`), tagged v0.1.0, GitHub release created 2026-03-24. `enforce_admins` restored.
**PR #2 MERGED** — `e302af4f` 2026-03-24 — README Scope section + v0.1.0 retro + Copilot PR#2 fixes. `enforce_admins` restored.

---

## Purpose

Standalone CLI exposing lib-foundation's agent rigor framework as three subcommands:
- `bin/rigor checkpoint` — `_agent_checkpoint`: stage all + commit
- `bin/rigor audit` — `_agent_audit`: staged .sh file checks (if-count, bare sudo, credentials, tab indent)
- `bin/rigor lint` — `_agent_lint` / shellcheck: all .sh files in repo

lib-foundation consumed via git subtree at `scripts/lib/foundation/`.

---

## Version Roadmap

| Version | Status | Notes |
|---|---|---|
| v0.1.0 | **SHIPPED** | PR #1 merged (`f720184`) — initial dispatcher + subtree + BATS 3 tests; 2026-03-24; tagged v0.1.0 |
| v0.1.1 | **ACTIVE** | PR #3 open — mapfile compat + gist-01 install script |

---

## Open Items

- [x] **PR #1** — merged `f720184`; tagged v0.1.0; GitHub release created
- [x] **PR #2** — merged `e302af4f`; README Scope section; v0.1.0 retro; Copilot PR#2 findings fixed; `enforce_admins` restored
- [ ] **PR #3** — open; mapfile compat fix + gist-01 install script; awaiting CI + Copilot
- [ ] **lib-foundation `.clinerules` fix** — PR #16 open in lib-foundation `feat/v0.3.10`; subtree pull after merge
- [ ] **Gist 1 publish** — publish `docs/gists/gist-01-agent-rigor/install.sh` to GitHub Gists after PR #3 merges

---

## Key Contracts (must not change without coordinating consumers)

- `bin/rigor checkpoint | audit | lint` — subcommand signatures
- `scripts/lib/foundation/` — read-only subtree; never edit directly

---

## Consumers

| Repo | Integration | Status |
|---|---|---|
| any Bash repo | git subtree or copy | planned |
| k3d-manager | subtree pull (future) | not yet wired |

---

## Engineering Protocol

- **Tests**: always run with `env -i PATH="/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin" HOME="$HOME" TMPDIR="$TMPDIR" bash --norc --noprofile -c 'bats scripts/tests/rigor.bats'`
- **shellcheck**: `shellcheck bin/rigor` before every commit
- **Subtree updates**: `git subtree pull --prefix=scripts/lib/foundation https://github.com/wilddog64/lib-foundation.git main --squash`
- **All changes originate here** — never edit `scripts/lib/foundation/` directly
