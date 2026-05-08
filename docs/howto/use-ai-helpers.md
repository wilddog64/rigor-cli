# How-To: Use the ai-* Helpers

`ai-bootstrap`, `ai-lint`, and `ai-review` are thin wrappers in `bin/` that
make rigor-cli easier to invoke from CI, pre-commit hooks, or the shell.
They live in `rigor-cli/bin/` and are consumed by client repos via symlinks.

---

## Setup

Run once from the client repo root:

```bash
bash tools/rigor-cli/docs/gists/gist-02-ai-helpers/setup-ai-helpers.sh
```

This creates `bin/ai-bootstrap`, `bin/ai-lint`, `bin/ai-review` as relative
symlinks into `tools/rigor-cli/bin/`. After a subtree pull, re-run with `--update`
to refresh the symlinks.

---

## ai-bootstrap

Verifies (and optionally installs) the lint backend before running lint or review.

```bash
bin/ai-bootstrap                  # check for ruff
bin/ai-bootstrap --install        # install ruff if missing
bin/ai-bootstrap --backend-cmd mypy
```

| Env var | Default | Purpose |
|---------|---------|---------|
| `RIGOR_PYTHON_BIN` | `python3` | Interpreter used to `pip install ruff` |

Run this once in CI before `ai-lint` to avoid silent backend-missing failures.

---

## ai-lint

Runs `rigor lint` with per-language backend dispatch.

```bash
bin/ai-lint                        # lint all tracked files
bin/ai-lint src/foo.py             # lint specific file
git diff --name-only | bin/ai-lint # lint changed files
```

| Env var | Default | Purpose |
|---------|---------|---------|
| `RIGOR_LINT_BACKEND_CMD` | `ruff` | Backend for Python files |
| `RIGOR_LINT_BACKENDS` | `py:<cmd>` | Full backends spec; overrides `RIGOR_LINT_BACKEND_CMD` |

---

## ai-review

Runs `rigor review` with a configurable prompt, stdin diff support, and CI
fail-on-findings mode.

```bash
bin/ai-review                              # review with default prompt
git diff main...HEAD | bin/ai-review       # pipe diff as context
bin/ai-review --prompt "focus on security"
bin/ai-review --fail-on-findings           # exit 1 if findings found (CI)
bin/ai-review --model claude-sonnet-4-6
```

**Default prompt resolution order** (first match wins):
1. `RIGOR_REVIEW_DEFAULT_PROMPT` env var
2. `.rigor/review-prompt` file in repo root
3. Built-in generic default

| Env var | Default | Purpose |
|---------|---------|---------|
| `RIGOR_REVIEW_DEFAULT_PROMPT` | built-in | Override the default review prompt |
| `RIGOR_REVIEW_MAX_LINES` | `5000` | Truncate stdin diff at this many lines |
| `AI_REVIEW_MODEL` | — | Model to pass to `rigor review` |
| `AI_REVIEW_STREAM` | `on` | Streaming mode: `on`\|`off` |
| `AI_REVIEW_FAIL_ON_FINDINGS` | `0` | Set to `1` to enable fail-on-findings globally |

### CI usage

```yaml
- name: ai-review
  run: git diff origin/main...HEAD | bin/ai-review --fail-on-findings
```

The review output must end with `AI_REVIEW_RESULT: findings` or
`AI_REVIEW_RESULT: no-findings` for `--fail-on-findings` to work. If the marker
is absent, the step fails closed.

---

## Updating rigor-cli

```bash
bash setup-ai-helpers.sh --update
# equivalent to:
git subtree pull --prefix=tools/rigor-cli \
  https://github.com/wilddog64/rigor-cli.git main --squash
```
