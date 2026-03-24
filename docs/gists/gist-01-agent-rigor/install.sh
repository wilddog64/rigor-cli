#!/usr/bin/env bash
# install.sh — wire rigor-cli into any Bash project
#
# Usage:
#   bash install.sh          # interactive (asks about CI workflow)
#   bash install.sh --ci     # non-interactive: also write .github/workflows/rigor.yml
#   bash install.sh --no-ci  # non-interactive: skip CI workflow
#
# What it does:
#   1. git subtree add --prefix=.rigor https://github.com/wilddog64/rigor-cli.git main --squash
#   2. Creates bin/rigor wrapper
#   3. Installs .git/hooks/pre-commit
#   4. Optionally writes .github/workflows/rigor.yml

set -euo pipefail

RIGOR_REPO="https://github.com/wilddog64/rigor-cli.git"
RIGOR_BRANCH="main"
RIGOR_PREFIX=".rigor"

_info() { printf 'INFO: %s\n' "$*"; }
_err()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

_check_deps() {
  command -v git >/dev/null 2>&1  || _err "git is required"
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || _err "must run from inside a git repo"
}

_add_subtree() {
  if [[ -d "${RIGOR_PREFIX}" ]]; then
    _info ".rigor/ already exists — skipping subtree add"
    return 0
  fi
  _info "Adding rigor-cli subtree at ${RIGOR_PREFIX}/ ..."
  git subtree add --prefix="${RIGOR_PREFIX}" "${RIGOR_REPO}" "${RIGOR_BRANCH}" --squash
}

_create_bin_wrapper() {
  mkdir -p bin
  if [[ -f bin/rigor ]]; then
    _info "bin/rigor already exists — skipping"
    return 0
  fi
  _info "Creating bin/rigor wrapper ..."
  cat > bin/rigor <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
exec "$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.rigor/bin/rigor" "$@"
SCRIPT
  chmod +x bin/rigor
}

_install_pre_commit() {
  if [[ -f .git/hooks/pre-commit ]]; then
    _info ".git/hooks/pre-commit already exists — skipping"
    return 0
  fi
  _info "Installing pre-commit hook ..."
  cat > .git/hooks/pre-commit <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail
bin/rigor audit
HOOK
  chmod +x .git/hooks/pre-commit
}

_write_ci_workflow() {
  mkdir -p .github/workflows
  if [[ -f .github/workflows/rigor.yml ]]; then
    _info ".github/workflows/rigor.yml already exists — skipping"
    return 0
  fi
  _info "Writing .github/workflows/rigor.yml ..."
  cat > .github/workflows/rigor.yml <<'YAML'
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
        run: sudo apt-get update && sudo apt-get install -y shellcheck
      - name: rigor lint
        run: bin/rigor lint
YAML
}

_prompt_ci() {
  local answer
  printf 'Write .github/workflows/rigor.yml CI workflow? [y/N] '
  read -r answer || true
  case "${answer,,}" in
    y|yes) return 0 ;;
    *)     return 1 ;;
  esac
}

main() {
  local ci_flag=""
  for arg in "$@"; do
    case "$arg" in
      --ci)    ci_flag="yes" ;;
      --no-ci) ci_flag="no"  ;;
    esac
  done

  _check_deps
  _add_subtree
  _create_bin_wrapper
  _install_pre_commit

  if [[ "$ci_flag" == "yes" ]]; then
    _write_ci_workflow
  elif [[ "$ci_flag" == "no" ]]; then
    _info "Skipping CI workflow (--no-ci)"
  elif _prompt_ci; then
    _write_ci_workflow
  fi

  _info "Done. Run 'bin/rigor audit' to verify."
}

main "$@"
