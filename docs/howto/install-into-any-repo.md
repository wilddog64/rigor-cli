# How-To: Install rigor-cli into Any Bash Project

Add shell quality enforcement (pre-commit audit, CI shellcheck, checkpoint commits) to any repo in one command.

---

## Prerequisites

- `git` with `git subtree` support (included in git ≥ 1.7.11)
- `shellcheck` — for `rigor lint` (`brew install shellcheck` or `apt-get install shellcheck`)
- bash ≥ 3.2

---

## One-Command Install

```bash
curl -fsSL https://gist.githubusercontent.com/wilddog64/81c767a0560e39c8d6e0f8bd9706973b/raw/install.sh | bash
```

This runs interactively and asks whether to also write a CI workflow. To skip the prompt:

```bash
# Non-interactive: include CI workflow
curl -fsSL https://gist.githubusercontent.com/wilddog64/81c767a0560e39c8d6e0f8bd9706973b/raw/install.sh | bash -s -- --ci

# Non-interactive: skip CI workflow
curl -fsSL https://gist.githubusercontent.com/wilddog64/81c767a0560e39c8d6e0f8bd9706973b/raw/install.sh | bash -s -- --no-ci
```

---

## What Gets Installed

| Step | Result |
|------|--------|
| `git subtree add` | `.rigor/` — versioned copy of rigor-cli, updatable |
| `bin/rigor` wrapper | Thin shell wrapper that delegates to `.rigor/bin/rigor` |
| `.git/hooks/pre-commit` | Runs `rigor audit` on every commit — blocks tab-indented, bare sudo, hardcoded credentials |
| `.github/workflows/rigor.yml` | (optional) CI — shellcheck all `.sh` files on every push/PR |

---

## Manual Install (step by step)

If you prefer not to pipe from curl:

```bash
# 1. Add rigor-cli as a git subtree
git subtree add --prefix=.rigor \
  https://github.com/wilddog64/rigor-cli.git main --squash

# 2. Create bin/rigor wrapper
mkdir -p bin
printf '#!/usr/bin/env bash\nexec "$(dirname "${BASH_SOURCE[0]}")/../.rigor/bin/rigor" "$@"\n' \
  > bin/rigor && chmod +x bin/rigor

# 3. Install pre-commit hook
printf '#!/usr/bin/env bash\nset -euo pipefail\nbin/rigor audit\n' \
  > .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

# 4. Verify
bin/rigor audit    # should pass on a clean working tree
bin/rigor lint     # shellcheck all .sh files
```

---

## Verify the Install

```bash
bin/rigor audit              # check staged .sh files
bin/rigor lint               # shellcheck all .sh files in repo
bin/rigor checkpoint         # stage all + commit checkpoint
```

---

## Update rigor-cli Later

```bash
git subtree pull --prefix=.rigor \
  https://github.com/wilddog64/rigor-cli.git main --squash
```

---

## Scope

rigor-cli only checks files with a `.sh` extension. Scripts without the extension (e.g. `bin/deploy`) are not picked up automatically — pass them explicitly:

```bash
bin/rigor lint bin/deploy
```

Non-shell code (Python, Go, Java, etc.) is out of scope — use language-specific linters for those.
