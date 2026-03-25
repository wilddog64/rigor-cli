# Active Context — rigor-cli

## Current State: `feat/v0.1.2` (as of 2026-03-25)

**v0.1.0 SHIPPED** — PR #1 merged to main (`f720184`), tagged v0.1.0, GitHub release created 2026-03-24. `enforce_admins` restored.
**PR #2 MERGED** — `e302af4f` 2026-03-24 — README Scope section + v0.1.0 retro + Copilot PR#2 fixes. `enforce_admins` restored.
**PR #3 MERGED** — `f304c14` 2026-03-24 — mapfile compat + gist-01; Copilot 4 findings fixed; enforce_admins restored.
**PR #4 MERGED** — `c5bda1e` 2026-03-25 — v0.1.1 milestone close-out; symlink debt resolved; how-to doc; Copilot 2 findings fixed. `enforce_admins` restored.
**v0.1.1 SHIPPED** — tagged `c5bda1e`, GitHub release created 2026-03-25.
**feat/v0.1.2 ACTIVE** — branch cut from `c5bda1e`.

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
| v0.1.1 | **SHIPPED** | PR #4 merged (`c5bda1e`) — bash 3.2 compat, gist-01 install, subtree path fix; 2026-03-25; tagged v0.1.1 |
| v0.1.2 | **ACTIVE** | branch `feat/v0.1.2` cut from `c5bda1e` |

---

## Open Items

- [x] **PR #1** — merged `f720184`; tagged v0.1.0; GitHub release created
- [x] **PR #2** — merged `e302af4f`; README Scope section; v0.1.0 retro; Copilot PR#2 findings fixed; `enforce_admins` restored
- [x] **PR #3** — merged `f304c14`; mapfile compat + gist-01; Copilot 4 findings fixed; enforce_admins restored
- [x] **lib-foundation `.clinerules` fix** — PR #16 merged (`c5662c9`); subtree pulled into rigor-cli
- [x] **Symlink tech debt** — `_RIGOR_LIB_DIR` updated to real subtree path (`c283d48`); BATS 3/3
- [x] **Gist 1 publish** — https://gist.github.com/wilddog64/81c767a0560e39c8d6e0f8bd9706973b
- [x] **PR #4** — merged `c5bda1e`; v0.1.1 tagged + released; enforce_admins restored; retro written

---

## Key Contracts (must not change without coordinating consumers)

- `bin/rigor checkpoint | audit | lint` — subcommand signatures
- `scripts/lib/foundation/` — read-only subtree; never edit directly

---

## Consumers

| Repo | Integration | Status |
|---|---|---|
| any Bash repo | git subtree via gist-01 install | available |
| k3d-manager | subtree pull (future) | not yet wired |

---

## Engineering Protocol

- **Tests**: always run with `env -i PATH="/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin" HOME="$HOME" TMPDIR="$TMPDIR" bash --norc --noprofile -c 'bats scripts/tests/rigor.bats'`
- **shellcheck**: `shellcheck bin/rigor` before every commit
- **Subtree updates**: `git subtree pull --prefix=scripts/lib/foundation https://github.com/wilddog64/lib-foundation.git main --squash`
- **All changes originate here** — never edit `scripts/lib/foundation/` directly
