# rigor-cli

Standalone CLI for the [lib-foundation](https://github.com/wilddog64/lib-foundation) agent rigor framework. Enforces Bash code quality in any repo — pre-commit hook, CI, or on demand. No Kubernetes dependency.

## Contents

| File | Purpose |
|---|---|
| `bin/rigor` | Dispatcher — `checkpoint \| audit \| lint` subcommands |
| `scripts/lib/foundation/` | lib-foundation git subtree — `_agent_checkpoint`, `_agent_audit`, `_agent_lint` |
| `scripts/tests/rigor.bats` | BATS test suite |

## Integration

Install into your repo via **git subtree**:

```bash
# Add as subtree (first time)
git subtree add --prefix=.rigor \
  https://github.com/wilddog64/rigor-cli.git main --squash

# Create bin/rigor wrapper
mkdir -p bin
printf '#!/usr/bin/env bash\nexec "$(dirname "${BASH_SOURCE[0]}")/../.rigor/bin/rigor" "$@"\n' \
  > bin/rigor && chmod +x bin/rigor

# Install pre-commit hook
printf '#!/usr/bin/env bash\nset -euo pipefail\nbin/rigor audit\n' \
  > .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

# Pull updates
git subtree pull --prefix=.rigor \
  https://github.com/wilddog64/rigor-cli.git main --squash
```

## Consumers

- [`k3d-manager`](https://github.com/wilddog64/k3d-manager) — local Kubernetes platform manager
- [`lib-foundation`](https://github.com/wilddog64/lib-foundation) — upstream source library

## Key Contracts

### `rigor audit`

Runs `_agent_audit` on staged `.sh` files. Fails the commit if any staged file contains:

```bash
rigor audit    # run on staged .sh files — use as pre-commit hook
```

Checks enforced:
- If-count ≤ 8 per function (signals need to split)
- No bare `sudo` — must use `_run_command --interactive-sudo` or `--prefer-sudo`
- No hardcoded credentials (passwords, tokens, secrets)
- 2-space indentation — tab or mixed indent fails

### `rigor lint [file…]`

Runs `shellcheck` on the specified files, or all `.sh` files in the repo if none given:

```bash
rigor lint                          # shellcheck all .sh files
rigor lint scripts/lib/system.sh    # shellcheck specific file
```

### `rigor checkpoint`

Stages all changes and creates a git checkpoint commit:

```bash
rigor checkpoint    # git add -A + git commit (safe mid-task save point)
```

## CI Integration

Add `.github/workflows/rigor.yml` to your repo:

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
