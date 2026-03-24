# rigor-cli

Standalone CLI for the [lib-foundation](https://github.com/wilddog64/lib-foundation) agent rigor framework. Enforces Bash code quality in any repo — runs as a pre-commit hook, in CI, or on demand.

Three subcommands cover the full spec-driven workflow: `audit` catches style and security violations at commit time, `lint` runs shellcheck across all shell files in CI, and `checkpoint` creates a safe mid-task save point during development. No Kubernetes dependency — works with any Bash project.

## Scope

rigor-cli enforces quality on **Bash/shell scripts only**. It checks staged `.sh` files at commit time and runs `shellcheck` on `.sh` files in CI. Non-shell code (Python, Go, Ruby, etc.) is out of scope — use language-specific linters for those.

If your repo is primarily non-shell, rigor-cli still guards the shell layer: CI scripts, install helpers, `bin/` tooling, and any `.sh` files checked into the repo.

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
bin/rigor audit               # check staged .sh files — use as pre-commit hook
bin/rigor lint                # shellcheck all .sh files in the repo
bin/rigor lint path/to/foo.sh # shellcheck specific file(s)
bin/rigor checkpoint          # stage all + commit checkpoint (safe mid-task save)
```

---

## What It Checks

### `rigor audit` — pre-commit enforcement

Runs on staged `.sh` files only. Fails the commit if any file contains:

| Check | What Fails |
|---|---|
| If-count | Functions with more than 8 `if` statements — split the function |
| Bare `sudo` | Direct `sudo` calls — use `_run_command --interactive-sudo` or `--prefer-sudo` |
| Hardcoded credentials | Passwords, tokens, secrets in plain text |
| Tab indentation | Tab or mixed space+tab indent — enforce 2-space style |

### `rigor lint` — shellcheck

Runs `shellcheck` on specified files or all `.sh` files in the repo. Catches:
- Unquoted variable expansions
- Missing `set -euo pipefail`
- Command injection risks and other shellcheck-detected issues

### `rigor checkpoint`

Stages all changes (`git add -A`) and creates a checkpoint commit. Use during multi-step development tasks to preserve a known-good state before continuing.

---

## Directory Layout

```
bin/
  rigor                    # dispatcher (checkpoint | audit | lint)
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

### Key Contracts

#### `rigor audit`

```bash
rigor audit    # exits 0 if all staged .sh files pass; non-zero on any violation
```

Backed by `_agent_audit` from [lib-foundation](https://github.com/wilddog64/lib-foundation/blob/main/scripts/lib/agent_rigor.sh). Only staged files are checked — unstaged changes are ignored.

#### `rigor lint [file…]`

```bash
rigor lint                          # shellcheck all tracked .sh files
rigor lint scripts/lib/system.sh    # shellcheck specific file
```

Defaults to `git ls-files '*.sh'` when no files are specified.

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
| [v0.1.0](https://github.com/wilddog64/rigor-cli/releases/tag/v0.1.0) | 2026-03-24 | Initial release — `checkpoint \| audit \| lint` dispatcher; lib-foundation v0.3.8 subtree; BATS 3 tests |
