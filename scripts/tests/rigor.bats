#!/usr/bin/env bats

setup() {
  BATS_TEST_TMPDIR="$(mktemp -d)"
  git -C "$BATS_TEST_TMPDIR" init >/dev/null
  git -C "$BATS_TEST_TMPDIR" config user.email "test@example.com"
  git -C "$BATS_TEST_TMPDIR" config user.name "Test User"
  touch "$BATS_TEST_TMPDIR/.gitkeep"
  git -C "$BATS_TEST_TMPDIR" add .gitkeep
  git -C "$BATS_TEST_TMPDIR" commit -m "init" >/dev/null
  local repo_root="${BATS_TEST_DIRNAME}/../.."
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cp "$repo_root/bin/rigor" "$BATS_TEST_TMPDIR/bin/rigor"
  chmod +x "$BATS_TEST_TMPDIR/bin/rigor"
  mkdir -p "$BATS_TEST_TMPDIR/scripts/lib"
  cp -R "$repo_root/scripts/lib/foundation" "$BATS_TEST_TMPDIR/scripts/lib/"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

teardown() {
  rm -rf "$BATS_TEST_TMPDIR"
}

@test "rigor audit passes on clean staged file" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  mkdir -p scripts
  printf 'function ok() {\n  echo "ok"\n}\n' > scripts/ok.sh
  git add scripts/ok.sh
  run bin/rigor audit
  [ "$status" -eq 0 ]
}

@test "rigor audit fails on tab-indented file" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  mkdir -p scripts
  printf 'function tabbed() {\n\techo "tab"\n}\n' > scripts/tabbed.sh
  git add scripts/tabbed.sh
  run bin/rigor audit
  [ "$status" -ne 0 ]
}

@test "rigor lint exits non-zero on shellcheck violation" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  mkdir -p scripts
  printf 'function lint_fail() {\n  echo $foo\n}\n' > scripts/lint_fail.sh
  run bin/rigor lint scripts/lint_fail.sh
  [ "$status" -ne 0 ]
}

@test "rigor lint: RIGOR_LINT_BACKENDS dispatches .py files to configured backend" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  printf '#!/usr/bin/env bash\nprintf "mock-ruff: %%s\\n" "$@"\n' \
    > "$BATS_TEST_TMPDIR/bin/ruff" && chmod +x "$BATS_TEST_TMPDIR/bin/ruff"
  mkdir -p src
  printf 'x = 1\n' > src/main.py
  git add src/main.py
  RIGOR_LINT_BACKENDS="sh:shellcheck py:ruff" run bin/rigor lint
  [ "$status" -eq 0 ]
  [[ "$output" == *"mock-ruff"* ]]
  [[ "$output" == *"main.py"* ]]
}

@test "rigor lint: missing backend emits warning and exits 0" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  mkdir -p src
  printf 'x = 1\n' > src/main.py
  git add src/main.py
  RIGOR_LINT_BACKENDS="py:definitely-not-installed-linter-xyz" run bin/rigor lint
  [ "$status" -eq 0 ]
  [[ "$output" == *"not found"* ]]
}

@test "rigor lint: explicit file arg only runs backend matching extension" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  printf '#!/usr/bin/env bash\nprintf "mock-ruff: %%s\\n" "$@"\n' \
    > "$BATS_TEST_TMPDIR/bin/ruff" && chmod +x "$BATS_TEST_TMPDIR/bin/ruff"
  mkdir -p src scripts
  printf 'x = 1\n' > src/main.py
  printf 'function ok() {\n  echo "ok"\n}\n' > scripts/ok.sh
  RIGOR_LINT_BACKENDS="sh:shellcheck py:ruff" run bin/rigor lint src/main.py
  [ "$status" -eq 0 ]
  [[ "$output" == *"mock-ruff"* ]]
  [[ "$output" != *"shellcheck"* ]]
}

@test "rigor lint: extensionless explicit file is silently skipped" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  printf '#!/usr/bin/env bash\necho "hello"\n' > bin/myscript
  chmod +x bin/myscript
  run bin/rigor lint bin/myscript
  [ "$status" -eq 0 ]
  [[ "$output" != *"shellcheck"* ]]
}

# ── ai-bootstrap tests ────────────────────────────────────────────────────────

_setup_ai_scripts() {
  local repo_root="${BATS_TEST_DIRNAME}/../.."
  cp "$repo_root/bin/ai-bootstrap" "$BATS_TEST_TMPDIR/bin/ai-bootstrap"
  cp "$repo_root/bin/ai-lint"      "$BATS_TEST_TMPDIR/bin/ai-lint"
  cp "$repo_root/bin/ai-review"    "$BATS_TEST_TMPDIR/bin/ai-review"
  chmod +x "$BATS_TEST_TMPDIR/bin/ai-bootstrap" \
            "$BATS_TEST_TMPDIR/bin/ai-lint" \
            "$BATS_TEST_TMPDIR/bin/ai-review"
}

@test "ai-bootstrap: errors when rigor binary is missing" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  _setup_ai_scripts
  rm -f "$BATS_TEST_TMPDIR/bin/rigor"
  run "$BATS_TEST_TMPDIR/bin/ai-bootstrap"
  [ "$status" -ne 0 ]
  [[ "$output" == *"rigor not found"* ]]
}

@test "ai-bootstrap: reports ready when backend command exists" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  _setup_ai_scripts
  printf '#!/usr/bin/env bash\nexit 0\n' > "$BATS_TEST_TMPDIR/bin/ruff"
  chmod +x "$BATS_TEST_TMPDIR/bin/ruff"
  run "$BATS_TEST_TMPDIR/bin/ai-bootstrap"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Backend ready: ruff"* ]]
}

@test "ai-bootstrap: errors when backend missing and --install not given" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  _setup_ai_scripts
  run env PATH="$BATS_TEST_TMPDIR/bin:$PATH" "$BATS_TEST_TMPDIR/bin/ai-bootstrap" --backend-cmd definitely-missing-xyz
  [ "$status" -ne 0 ]
  [[ "$output" == *"Missing backend command"* ]]
}

# ── ai-lint tests ─────────────────────────────────────────────────────────────

@test "ai-lint: errors when rigor binary is missing" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  _setup_ai_scripts
  rm -f "$BATS_TEST_TMPDIR/bin/rigor"
  run "$BATS_TEST_TMPDIR/bin/ai-lint"
  [ "$status" -ne 0 ]
  [[ "$output" == *"rigor not found"* ]]
}

@test "ai-lint: delegates to rigor lint with RIGOR_LINT_BACKENDS set" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  _setup_ai_scripts
  printf '#!/usr/bin/env bash\nprintf "rigor-called: %%s\\n" "$*"\n' \
    > "$BATS_TEST_TMPDIR/bin/rigor" && chmod +x "$BATS_TEST_TMPDIR/bin/rigor"
  run "$BATS_TEST_TMPDIR/bin/ai-lint"
  [ "$status" -eq 0 ]
  [[ "$output" == *"rigor-called"* ]]
  [[ "$output" == *"lint"* ]]
}

# ── ai-review tests ───────────────────────────────────────────────────────────

@test "ai-review: uses .rigor/review-prompt when present" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  _setup_ai_scripts
  mkdir -p .rigor
  printf 'my-custom-prompt' > .rigor/review-prompt
  printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$*"\n' \
    > "$BATS_TEST_TMPDIR/bin/rigor" && chmod +x "$BATS_TEST_TMPDIR/bin/rigor"
  run "$BATS_TEST_TMPDIR/bin/ai-review"
  [ "$status" -eq 0 ]
  [[ "$output" == *"my-custom-prompt"* ]]
}

@test "ai-review: RIGOR_REVIEW_DEFAULT_PROMPT overrides .rigor/review-prompt" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  _setup_ai_scripts
  mkdir -p .rigor
  printf 'file-prompt' > .rigor/review-prompt
  printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$*"\n' \
    > "$BATS_TEST_TMPDIR/bin/rigor" && chmod +x "$BATS_TEST_TMPDIR/bin/rigor"
  RIGOR_REVIEW_DEFAULT_PROMPT="env-prompt" run "$BATS_TEST_TMPDIR/bin/ai-review"
  [ "$status" -eq 0 ]
  [[ "$output" == *"env-prompt"* ]]
  [[ "$output" != *"file-prompt"* ]]
}

@test "ai-review: truncates stdin over RIGOR_REVIEW_MAX_LINES" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  _setup_ai_scripts
  printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$*"\n' \
    > "$BATS_TEST_TMPDIR/bin/rigor" && chmod +x "$BATS_TEST_TMPDIR/bin/rigor"
  # generate 20 lines, cap at 5
  run bash -c "seq 1 20 | RIGOR_REVIEW_MAX_LINES=5 $BATS_TEST_TMPDIR/bin/ai-review"
  [ "$status" -eq 0 ]
  [[ "$output" == *"truncated"* ]]
}
