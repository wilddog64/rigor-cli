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
  cp "$repo_root/bin/ai-triage-pod" "$BATS_TEST_TMPDIR/bin/ai-triage-pod"
  chmod +x "$BATS_TEST_TMPDIR/bin/ai-triage-pod"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$BATS_TEST_TMPDIR/bin/ai-review"
  chmod +x "$BATS_TEST_TMPDIR/bin/ai-review"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$BATS_TEST_TMPDIR/bin/kubectl"
  chmod +x "$BATS_TEST_TMPDIR/bin/kubectl"
  mkdir -p "$BATS_TEST_TMPDIR/.github"
  printf 'copilot-instructions' > "$BATS_TEST_TMPDIR/.github/copilot-instructions.md"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

teardown() {
  rm -rf "$BATS_TEST_TMPDIR"
}

@test "ai-triage-pod prints help with --help" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  run bin/ai-triage-pod --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: ai-triage-pod"* ]]
  [[ "$output" == *"-f, --context-file FILE"* ]]
}

@test "ai-triage-pod fails when arguments are missing" {
  cd "$BATS_TEST_TMPDIR" || exit 1
  run bin/ai-triage-pod identity
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage: ai-triage-pod"* ]]
}

@test "ai-triage-pod collects describe, logs, and context file content" {
  cd "$BATS_TEST_TMPDIR" || exit 1

  printf '#!/usr/bin/env bash\nprintf "ai-review: %%s\\n" "$*"\n' \
    > "$BATS_TEST_TMPDIR/bin/ai-review" && chmod +x "$BATS_TEST_TMPDIR/bin/ai-review"

  printf '#!/usr/bin/env bash\ncase "$1" in\n  describe)\n    printf "describe:%s\\n" "$*"\n    ;;\n  logs)\n    printf "logs:%s\\n" "$*"\n    ;;\n  *)\n    printf "kubectl:%s\\n" "$*"\n    ;;\nesac\n' \
    > "$BATS_TEST_TMPDIR/bin/kubectl" && chmod +x "$BATS_TEST_TMPDIR/bin/kubectl"

  printf 'file-context' > "$BATS_TEST_TMPDIR/context.txt"

  run bash -c "printf 'stdin-context' | bin/ai-triage-pod --context-file context.txt --tail 42 identity keycloak-1"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ai-review:"* ]]
  [[ "$output" == *"describe:describe pod -n identity keycloak-1"* ]]
  [[ "$output" == *"logs:logs -n identity keycloak-1 --previous --tail=42"* ]]
  [[ "$output" == *"=== context file: context.txt ==="* ]]
  [[ "$output" == *"file-context"* ]]
}

@test "ai-triage-pod -f file skips pod collection" {
  cd "$BATS_TEST_TMPDIR" || exit 1

  printf '#!/usr/bin/env bash\nprintf "ai-review: %%s\\n" "$*"\n' \
    > "$BATS_TEST_TMPDIR/bin/ai-review" && chmod +x "$BATS_TEST_TMPDIR/bin/ai-review"

  printf '#!/usr/bin/env bash\nprintf "kubectl:%s\\n" "$*" >&2\nexit 1\n' \
    > "$BATS_TEST_TMPDIR/bin/kubectl" && chmod +x "$BATS_TEST_TMPDIR/bin/kubectl"

  printf 'file-only-context' > "$BATS_TEST_TMPDIR/context.txt"

  run bin/ai-triage-pod -f context.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"ai-review:"* ]]
  [[ "$output" == *"=== context file: context.txt ==="* ]]
  [[ "$output" == *"file-only-context"* ]]
  [[ "$output" != *"describe pod"* ]]
  [[ "$output" != *"last 100 log lines"* ]]
}

@test "ai-triage-pod -f - reads stdin without pod collection" {
  cd "$BATS_TEST_TMPDIR" || exit 1

  printf '#!/usr/bin/env bash\nprintf "ai-review: %%s\\n" "$*"\n' \
    > "$BATS_TEST_TMPDIR/bin/ai-review" && chmod +x "$BATS_TEST_TMPDIR/bin/ai-review"

  printf '#!/usr/bin/env bash\nprintf "kubectl:%s\\n" "$*" >&2\nexit 1\n' \
    > "$BATS_TEST_TMPDIR/bin/kubectl" && chmod +x "$BATS_TEST_TMPDIR/bin/kubectl"

  run bash -c "printf 'stdin-only-context' | bin/ai-triage-pod -f -"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ai-review:"* ]]
  [[ "$output" == *"=== context file: - ==="* ]]
  [[ "$output" == *"stdin-only-context"* ]]
  [[ "$output" != *"describe pod"* ]]
  [[ "$output" != *"last 100 log lines"* ]]
}
