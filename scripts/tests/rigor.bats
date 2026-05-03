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
