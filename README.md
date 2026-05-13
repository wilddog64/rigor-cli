# rigor-cli

Standalone CLI for the [lib-foundation](https://github.com/wilddog64/lib-foundation) agent rigor framework. Enforces code quality across any language — runs as a pre-commit hook, in CI, or on demand.

Four subcommands cover the full spec-driven workflow: `audit` catches style and security violations at commit time, `lint` runs configured static analysis per language, `checkpoint` creates a safe mid-task save point during development, and `review` runs AI-assisted review via the configured backend. The `bin/ai-*` helpers extend that flow with backend setup, linting, review, and pod triage. No Kubernetes dependency — works with any project.

## Scope

rigor-cli enforces quality across **any language** via three mechanisms:

- **`rigor audit`** — pre-commit enforcement for `.sh` (style/security checks) and `.yaml`/`.yml` (hardcoded IP detection). These checks are extension-gated and apply only to the relevant file types.
- **`rigor lint`** — runs configured static analysis backends per extension. Default: `shellcheck` on `.sh`. Configure additional languages via `RIGOR_LINT_BACKENDS`.
- **`rigor review`** — AI-assisted review for any staged content, regardless of language.
- **`bin/ai-triage-pod`** — AI-assisted Kubernetes pod diagnosis that bundles `kubectl describe pod` and logs, plus optional stdin/file context.

Shell scripts without a `.sh` extension (e.g. `bin/rigor` itself) are not supported by `rigor lint` — extension matching is required. Use `shellcheck` directly for extensionless scripts.

---

## Quick Start

### 1. Add rigor-cli to your repo

```bash
# Add as git subtree (versioned, updatable)
git subtree add --prefix=.rigor \
  https://github.com/wilddog64/rigor-cli.git main --squash
```

### 2. Create bin/rigor wrapper

```bash
mkdir -p bin
printf '#!/usr/bin/env bash\nexec "$(dirname "${BASH_SOURCE[0]}")/../.rigor/bin/rigor" "$@"\n' \
  > bin/rigor && chmod +x bin/rigor
```

### 3. Install pre-commit hook

```bash
printf '#!/usr/bin/env bash\nset -euo pipefail\nbin/rigor audit\n' \
  > .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
```

### 4. Verify

```bash
bin/rigor audit    # should pass on clean working tree
bin/rigor lint     # shellcheck all .sh files
```

To update rigor-cli later:

```bash
git subtree pull --prefix=.rigor \
  https://github.com/wilddog64/rigor-cli.git main --squash
```

---

## Usage

```bash
bin/rigor audit               # check staged .sh and .yaml/.yml files — use as pre-commit hook
bin/rigor lint                # run all configured backends on tracked files
bin/rigor lint path/to/foo.sh # run matching backend for specific file(s)
bin/rigor checkpoint          # stage all + commit checkpoint (safe mid-task save)
bin/rigor review --prompt "review this change for shell injection"
bin/ai-triage-pod ns pod      # bundle describe/logs into ai-review for diagnosis
```

---

## What It Checks

### `rigor audit` — pre-commit enforcement

Runs on staged `.sh` and `.yaml`/`.yml` files. Fails the commit if any file contains:

| Check | Files | What Fails |
|---|---|---|
| If-count | `.sh` | Functions with more than 8 `if` statements — split the function |
| Bare `sudo` | `.sh` | Direct `sudo` calls — use `_run_command --interactive-sudo` or `--prefer-sudo` |
| Hardcoded credentials | `.sh` | Passwords, tokens, secrets in plain text |
| Tab indentation | `.sh` | Tab or mixed space+tab indent — enforce 2-space style |
| Hardcoded IP | `.yaml`/`.yml` | IPv4 addresses — use CoreDNS hostname (e.g. `svc.cluster.local`) instead |

### `rigor lint` — multi-language static analysis

Runs configured linter backends against tracked files grouped by extension. Controlled by
`RIGOR_LINT_BACKENDS` (space-separated `ext:command` pairs, default: `sh:shellcheck`).

| Env Var | Default | Description |
|---|---|---|
| `RIGOR_LINT_BACKENDS` | `sh:shellcheck` | Space-separated `ext:command` pairs. Each backend is called with all tracked files of that extension. Missing binaries produce a warning and are skipped — they do not fail the run. |

```bash
# Default: shellcheck all .sh files
bin/rigor lint

# Python + shell
RIGOR_LINT_BACKENDS="sh:shellcheck py:ruff" bin/rigor lint

# TypeScript + Python + shell
RIGOR_LINT_BACKENDS="sh:shellcheck py:ruff ts:eslint" bin/rigor lint

# Specific files (only runs backends whose extension matches)
bin/rigor lint src/main.py scripts/deploy.sh
```

### `rigor review` — AI review

Runs AI-assisted review through `_ai_agent_review` from lib-foundation. By default it uses Copilot with `AI_REVIEW_MODEL=gpt-5.4-mini`, and it warns when the calling repo does not have `.github/copilot-instructions.md`.

### `rigor checkpoint`

Stages all changes (`git add -A`) and creates a checkpoint commit. Use during multi-step development tasks to preserve a known-good state before continuing.

---

## Directory Layout

```
bin/
  rigor                    # dispatcher (checkpoint | audit | lint | review)
scripts/
  lib/foundation/          # lib-foundation git subtree (DO NOT EDIT)
  tests/
    rigor.bats             # BATS test suite
.github/
  workflows/
    ci.yml                 # shellcheck + BATS on every push/PR
```

---

## Documentation

### How-To

- [Install rigor-cli into any Bash project](docs/howto/install-into-any-repo.md) — one-command install, manual steps, update, scope

### Key Contracts

#### `rigor audit`

```bash
rigor audit    # exits 0 if all staged .sh and .yaml/.yml files pass; non-zero on any violation
```

Backed by `_agent_audit` from [lib-foundation](https://github.com/wilddog64/lib-foundation/blob/main/scripts/lib/agent_rigor.sh). Only staged files are checked — unstaged changes are ignored.

#### `rigor lint [file…]`

```bash
rigor lint                                    # run all configured backends on tracked files
rigor lint scripts/lib/system.sh              # run matching backend for .sh
RIGOR_LINT_BACKENDS="sh:shellcheck py:ruff" bin/rigor lint   # multi-language
```

Reads `RIGOR_LINT_BACKENDS` (default: `sh:shellcheck`). For each `ext:cmd` pair, collects tracked files with that extension and passes them to `cmd`. If a backend binary is missing, emits a warning and continues — does not fail. Returns non-zero if any backend fails.

#### `rigor review [--prompt <text>] [args…]`

```bash
rigor review --prompt "review this diff for security issues"
rigor review --prompt "check this function for shell injection"
```

Backed by `_ai_agent_review` from lib-foundation. Uses the backend selected by `AI_REVIEW_FUNC` (default: `copilot`) with `AI_REVIEW_MODEL` (default: `gpt-5.4-mini`).

#### `rigor checkpoint`

```bash
rigor checkpoint    # git add -A + git commit -m "checkpoint: <timestamp>"
```

Backed by `_agent_checkpoint` from lib-foundation. Requires a clean git repo (not mid-merge).

### CI Integration

Add `.github/workflows/rigor.yml` to your repo to run `rigor lint` on every push and PR:

```yaml
name: rigor
on:
  push:
    branches: ["**"]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
      - name: Install shellcheck
        run: sudo apt-get install -y shellcheck
      - name: rigor lint
        run: bin/rigor lint
```

---

## Development

```bash
# Run BATS tests (requires bats ≥ 1.11) — always use env -i for clean environment
env -i PATH="/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin" HOME="$HOME" TMPDIR="$TMPDIR" \
  bash --norc --noprofile -c 'bats scripts/tests/rigor.bats'

# shellcheck
shellcheck bin/rigor
```

## Code Style

- `set -euo pipefail` on all scripts
- Public functions: no leading underscore
- Private functions: prefix with `_`
- Double-quote all variable expansions
- No bare `sudo` — use `_run_command --interactive-sudo` for install helpers, `--prefer-sudo` for non-interactive contexts

## Requirements

- bash ≥ 3.2
- git
- shellcheck (for `rigor lint` — `brew install shellcheck` or `apt-get install shellcheck`)

---

## Releases

| Version | Date | Highlights |
|---|---|---|
| [v0.1.5](https://github.com/wilddog64/rigor-cli/releases/tag/v0.1.5) | 2026-05-08 | `bin/ai-bootstrap`, `bin/ai-lint`, `bin/ai-review` helpers; 8 BATS tests |
| [v0.1.4](https://github.com/wilddog64/rigor-cli/releases/tag/v0.1.4) | 2026-05-03 | `RIGOR_LINT_BACKENDS` multi-language dispatch; lint tests expanded to 6 |
| [v0.1.3](https://github.com/wilddog64/rigor-cli/releases/tag/v0.1.3) | 2026-05-03 | `review` subcommand via `_ai_agent_review`; lib-foundation v0.3.20 subtree pull |

<details><summary>Older releases</summary>

| Version | Date | Highlights |
|---|---|---|
| [v0.1.0](https://github.com/wilddog64/rigor-cli/releases/tag/v0.1.0) | 2026-03-24 | Initial release — `checkpoint \| audit \| lint` dispatcher; lib-foundation v0.3.8 subtree; BATS 3 tests |

</details>
