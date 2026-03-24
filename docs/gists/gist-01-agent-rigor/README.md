# gist-01: rigor-cli one-command install

Adds [rigor-cli](https://github.com/wilddog64/rigor-cli) to any Bash project.

## Usage

```bash
curl -fsSL https://gist.githubusercontent.com/wilddog64/81c767a0560e39c8d6e0f8bd9706973b/raw/install.sh | bash
# or clone + run manually:
bash install.sh --ci     # also write .github/workflows/rigor.yml
bash install.sh --no-ci  # skip CI workflow
```

## What it installs

| Step | Result |
|------|--------|
| git subtree add | `.rigor/` — versioned, updatable |
| bin/rigor wrapper | `bin/rigor` subcommands: `checkpoint`, `audit`, `lint` |
| pre-commit hook | `.git/hooks/pre-commit` — runs `rigor audit` |
| CI workflow (optional) | `.github/workflows/rigor.yml` — shellcheck on every push/PR |

## Update later

```bash
git subtree pull --prefix=.rigor https://github.com/wilddog64/rigor-cli.git main --squash
```
