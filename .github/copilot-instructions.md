# GitHub Copilot Instructions — rigor-cli

rigor-cli is a standalone CLI dispatcher over [lib-foundation](https://github.com/wilddog64/lib-foundation)'s agent rigor framework. It exposes three subcommands (`checkpoint`, `audit`, `lint`) backed by `_agent_checkpoint`, `_agent_audit`, and `_agent_lint` from the lib-foundation git subtree at `scripts/lib/foundation/`.

Use the rules below to shape all code suggestions and PR reviews.

---

## Architecture

- **Dispatcher**: `bin/rigor` — thin bash script, sources lib-foundation, dispatches to `_agent_*` functions
- **Subtree**: `scripts/lib/foundation/` — lib-foundation copy; **DO NOT EDIT** — all changes go upstream first
- **Tests**: `scripts/tests/rigor.bats` — always run with `env -i` clean environment
- **CI**: `.github/workflows/ci.yml` — shellcheck + BATS on every push and PR

---

## Review Focus

### Supply Chain (OWASP A08) — P1

- GitHub Actions steps must pin to a version tag (`@v4`) — never `@main` or `@latest`
- External tools cloned in CI (e.g. bats-core) must pin to a specific release tag — never clone the default branch unversioned

### Shell Injection (OWASP A03)

- All variable expansions in command arguments must be double-quoted: `"$var"`, not `$var`
- Never pass user-supplied input to `eval`
- Use `--` to separate options from arguments where arguments may contain hyphens

### Bash 3.2 Compatibility (macOS ships /bin/bash 3.2)

Flag any of the following as blocking issues:

- **`local -n`** (nameref) — requires bash 4.3+; breaks on macOS
- **`declare -A`** (associative arrays) — not available in bash 3.2
- **`mapfile`** / **`readarray`** — not available in bash 3.2

Note: `mapfile` is currently used in `bin/rigor`'s `_rigor_shellcheck` for the default-files case. This is a known limitation — acceptable for v0.1.0 since CI runs on Ubuntu; flag if macOS compatibility becomes a requirement.

### Privilege Escalation

- No bare `sudo` in `bin/rigor` or any script outside the lib-foundation subtree
- Privilege escalation (if ever needed) must use `_run_command --prefer-sudo` or `--require-sudo`

### Secret Hygiene (OWASP A02)

- No hardcoded credentials, tokens, or IP addresses in any file

---

## Skip / Do Not Flag

- Any file under `scripts/lib/foundation/` — this is a read-only git subtree; upstream changes belong in lib-foundation
- `set -euo pipefail` absence in sourced library files — these are sourced, not executed directly
- Test stubs and helper overrides in `scripts/tests/` — intentionally override production functions
- `shellcheck disable=SC1091` directives in `bin/rigor` — sourced paths are dynamic, suppression is intentional

---

## Code Style

- `set -euo pipefail` on all new scripts
- Public functions: no leading underscore
- Private/helper functions: prefix with `_`
- Double-quote all variable expansions
- LF line endings only — no CRLF
- No inline comments unless logic is non-obvious
