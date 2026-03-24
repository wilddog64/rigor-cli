# rigor-cli

Standalone CLI for the [lib-foundation](https://github.com/wilddog64/lib-foundation) agent rigor framework.

## Install

```bash
# Add to your repo as a git subtree
git subtree add --prefix=bin/rigor-cli \
  https://github.com/wilddog64/rigor-cli.git main --squash

# Or just copy bin/rigor into your repo's bin/
```

## Usage

```bash
rigor checkpoint          # stage all + commit checkpoint
rigor audit               # check staged .sh files (runs pre-commit checks)
rigor lint [file…]        # shellcheck on specified files
```

## Requirements

- bash ≥ 3.2
- git
- shellcheck (for `rigor lint`)

## Consumers

- [k3d-manager](https://github.com/wilddog64/k3d-manager)
