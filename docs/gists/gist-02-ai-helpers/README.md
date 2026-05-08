# gist-02: ai-helpers one-command setup

Pulls [rigor-cli](https://github.com/wilddog64/rigor-cli) as a subtree and wires
`bin/ai-bootstrap`, `bin/ai-lint`, `bin/ai-review` as relative symlinks.

## Usage

```bash
# Fresh install (subtree add + symlinks)
bash setup-ai-helpers.sh

# Custom prefix / bin dir
bash setup-ai-helpers.sh --prefix tools/rigor-cli --bin-dir bin

# After a subtree pull (refresh symlinks)
bash setup-ai-helpers.sh --update
```

## What it installs

| Step | Result |
|------|--------|
| git subtree add | `tools/rigor-cli/` — versioned, updatable |
| `bin/ai-bootstrap` symlink | checks/installs ruff lint backend |
| `bin/ai-lint` symlink | runs `rigor lint` with per-language backend mapping |
| `bin/ai-review` symlink | runs `rigor review` with configurable prompt + CI mode |

## Update later

```bash
bash setup-ai-helpers.sh --update
# or manually:
git subtree pull --prefix=tools/rigor-cli \
  https://github.com/wilddog64/rigor-cli.git main --squash
```
