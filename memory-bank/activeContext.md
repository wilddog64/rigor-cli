# Active Context — rigor-cli

## Current Branch: `rigor-cli-v0.1.6`

**Status:** v0.1.5 shipped; enforce_admins restored; pyjenkinsapi branch protection set up; v0.1.6 now has the `ai-triage-pod` helper added, including `-f FILE` / `-f -` context-only triage mode.

## Recent Changes
- **`ai-triage-pod` updated** — commit `469474d` adds `-f FILE` / `-f -` context-only triage mode so the helper can diagnose standalone notes or stdin without requiring pod name lookup. Docs and tests updated in `docs/howto/ai-triage-pod.md` and `scripts/tests/ai-triage-pod.bats`. Tests and shellcheck passed.
- **v0.1.5 SHIPPED** — PR #8 merged to main (`7fc2017`), tagged v0.1.5, released 2026-05-08. ai-bootstrap, ai-lint, ai-review helpers + 8 BATS tests.
- **pyjenkinsapi PR #5 merged** — SHA `65621642`. Symlink refactor complete. CI updated to skip BATS pending subtree pull.
- **Branch protection** — pyjenkinsapi main now has 1 required review + enforce_admins enabled. rigor-cli enforce_admins restored.
- **Next branch** — rigor-cli-v0.1.6 created at `7fc2017`, retrospective added; now ahead by the ai-triage-pod helper commit.

## Next Steps
- Push `rigor-cli-v0.1.6` with the new helper commit and refresh the consumer subtree when ready.
- Pull rigor-cli subtree into pyjenkinsapi to activate ai-* symlinks.
- Phase 4: Full integration tests with various consumer repos.
