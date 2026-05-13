#!/usr/bin/env bash
# setup-ai-helpers.sh — wire rigor-cli ai-* helpers into any repo
#
# Usage (run from repo root):
#   bash setup-ai-helpers.sh                        # interactive subtree add + symlinks
#   bash setup-ai-helpers.sh --update               # pull latest rigor-cli, refresh symlinks
#   bash setup-ai-helpers.sh --prefix tools/rigor-cli --bin-dir bin
#
# What it does:
#   1. git subtree add/pull rigor-cli at <prefix>/
#   2. Creates bin/ai-bootstrap, bin/ai-lint, bin/ai-review, bin/ai-triage-pod as relative symlinks

set -euo pipefail

RIGOR_REPO="https://github.com/wilddog64/rigor-cli.git"
RIGOR_BRANCH="main"

_info() { printf 'INFO: %s\n' "$*"; }
_warn() { printf 'WARN: %s\n' "$*" >&2; }
_err()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

_check_deps() {
  command -v git >/dev/null 2>&1 || _err "git is required"
  git subtree --help >/dev/null 2>&1 || _err "git subtree is required"
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || _err "must run from inside a git repo"
}

# Compute relative path from <from_dir>/ to <to_path> without using realpath.
# Both arguments are repo-root-relative paths.
_rel_path() {
  local from_dir="$1" to_path="$2"
  local ups="" part
  local IFS="/"
  for part in $from_dir; do
    [[ -n "$part" ]] && ups="../$ups"
  done
  printf '%s%s' "$ups" "$to_path"
}

_subtree_add() {
  local prefix="$1"
  if [[ -d "$prefix" ]]; then
    _info "${prefix}/ already exists — skipping subtree add"
    return 0
  fi
  _info "Adding rigor-cli subtree at ${prefix}/ ..."
  git subtree add --prefix="$prefix" "$RIGOR_REPO" "$RIGOR_BRANCH" --squash
}

_subtree_pull() {
  local prefix="$1"
  _info "Pulling latest rigor-cli into ${prefix}/ ..."
  git subtree pull --prefix="$prefix" "$RIGOR_REPO" "$RIGOR_BRANCH" --squash
}

_create_symlinks() {
  local prefix="$1" bin_dir="$2"
  mkdir -p "$bin_dir"
  local helper
  for helper in ai-bootstrap ai-lint ai-review ai-triage-pod; do
    local link="${bin_dir}/${helper}"
    local target
    target="$(_rel_path "$bin_dir" "${prefix}/bin/${helper}")"
    if [[ -L "$link" ]]; then
      local current
      current="$(readlink "$link")"
      if [[ "$current" == "$target" ]]; then
        _info "${link} already points to ${target} — skipping"
        continue
      fi
      _info "Updating ${link}: ${current} → ${target}"
      rm "$link"
    elif [[ -e "$link" ]]; then
      _err "${link} exists and is not a symlink — remove it manually and re-run"
    fi
    ln -s "$target" "$link"
    _info "Created symlink: ${link} → ${target}"
  done
}

_verify_symlinks() {
  local bin_dir="$1" prefix="$2"
  local helper ok=1
  for helper in ai-bootstrap ai-lint ai-review ai-triage-pod; do
    local link="${bin_dir}/${helper}"
    if [[ ! -L "$link" ]]; then
      _warn "Missing symlink: ${link}"
      ok=0
    elif [[ ! -x "${prefix}/bin/${helper}" ]]; then
      _warn "Target not executable: ${prefix}/bin/${helper}"
      ok=0
    else
      _info "OK: ${link}"
    fi
  done
  [[ "$ok" -eq 1 ]]
}

main() {
  local prefix="tools/rigor-cli"
  local bin_dir="bin"
  local update=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --prefix)
        shift; [[ $# -gt 0 ]] || _err "--prefix requires a value"
        prefix="$1" ;;
      --bin-dir)
        shift; [[ $# -gt 0 ]] || _err "--bin-dir requires a value"
        bin_dir="$1" ;;
      --update) update=1 ;;
      -h|--help)
        sed -n '2,10p' "$0"; exit 0 ;;
      *)
        _err "Unknown argument: $1" ;;
    esac
    shift
  done

  _check_deps

  if [[ "$update" -eq 1 ]]; then
    _subtree_pull "$prefix"
  else
    _subtree_add "$prefix"
  fi

  _create_symlinks "$prefix" "$bin_dir"
  _verify_symlinks "$bin_dir" "$prefix"

  _info "Done. Try: ${bin_dir}/ai-triage-pod --help"
}

main "$@"
