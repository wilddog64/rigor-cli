# Bugfix: v0.1.6 — ai-* scripts fail when called via symlink

**Branch:** `rigor-cli-v0.1.6`
**Files:** `bin/ai-bootstrap`, `bin/ai-lint`, `bin/ai-review`

---

## Problem

When `bin/ai-bootstrap`, `bin/ai-lint`, or `bin/ai-review` are invoked through a symlink
(as in pyjenkinsapi's `bin/ai-* -> ../tools/rigor-cli/bin/ai-*`), the scripts fail with:

```
ERROR: rigor not found at <consumer-repo>/bin/rigor — check rigor-cli installation
```

**Root cause:** All three scripts locate the `rigor` binary relative to `${BASH_SOURCE[0]}`,
which resolves to the symlink path (`bin/ai-review`) rather than the real script path
(`tools/rigor-cli/bin/ai-review`). The `cd dirname` then points to the consumer `bin/`
directory where `rigor` doesn't live.

---

## Fix

Replace the `BASH_SOURCE[0]`-based lookup with a symlink-aware resolver in all three files.

### Change 1 — `bin/ai-bootstrap` line 47

**Old:**
```bash
_rigor_bin="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/rigor"
```

**New:**
```bash
_self="${BASH_SOURCE[0]}"
if [[ -L "$_self" ]]; then
  _link="$(readlink "$_self")"
  [[ "$_link" != /* ]] && _link="$(cd "$(dirname "$_self")" && pwd)/$_link"
  _self="$_link"
fi
_rigor_bin="$(cd -- "$(dirname -- "$_self")" && pwd)/rigor"
```

### Change 2 — `bin/ai-lint` line 25

**Old:**
```bash
_rigor_bin="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/rigor"
```

**New:**
```bash
_self="${BASH_SOURCE[0]}"
if [[ -L "$_self" ]]; then
  _link="$(readlink "$_self")"
  [[ "$_link" != /* ]] && _link="$(cd "$(dirname "$_self")" && pwd)/$_link"
  _self="$_link"
fi
_rigor_bin="$(cd -- "$(dirname -- "$_self")" && pwd)/rigor"
```

### Change 3 — `bin/ai-review` line 73

**Old:**
```bash
_default_rigor_bin="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/rigor"
```

**New:**
```bash
_self="${BASH_SOURCE[0]}"
if [[ -L "$_self" ]]; then
  _link="$(readlink "$_self")"
  [[ "$_link" != /* ]] && _link="$(cd "$(dirname "$_self")" && pwd)/$_link"
  _self="$_link"
fi
_default_rigor_bin="$(cd -- "$(dirname -- "$_self")" && pwd)/rigor"
```

---

## Definition of Done

- [ ] `bin/ai-review --help` works when called through pyjenkinsapi symlink
- [ ] `shellcheck -S warning` passes on all three files
- [ ] Committed and pushed to `rigor-cli-v0.1.6`

**Commit message:**
```
fix(bin): resolve symlink in BASH_SOURCE before locating rigor binary
```
