# Active Context — rigor-cli

## Current State: `feat/init` (as of 2026-03-24)

**v0.1.0 IN PROGRESS** — PR #1 open (`feat/init`); CI green; Copilot findings addressed (`b96470d`).

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
| v0.1.0 | **IN PROGRESS** | PR #1 open — initial dispatcher + subtree + BATS 3 tests |

---

## Open Items

- [ ] **PR #1** — merge feat/init → main; tag v0.1.0; create GitHub release
- [ ] **lib-foundation `.clinerules` fix** — `_detect_platform` values wrong in subtree; fix upstream in lib-foundation `feat/v0.3.10`
- [ ] **Gist 1 install script** — `docs/gists/gist-01-agent-rigor/` in k3d-manager; wire pre-commit + CI workflow

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
