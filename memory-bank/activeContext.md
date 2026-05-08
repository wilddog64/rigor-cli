# Active Context — rigor-cli

## Current Branch: `rigor-cli-v0.1.6`

**Status:** v0.1.5 shipped; enforce_admins restored; pyjenkinsapi branch protection set up; v0.1.6 next branch created.

## Recent Changes
- **v0.1.5 SHIPPED** — PR #8 merged to main (`7fc2017`), tagged v0.1.5, released 2026-05-08. ai-bootstrap, ai-lint, ai-review helpers + 8 BATS tests.
- **pyjenkinsapi PR #5 merged** — SHA `65621642`. Symlink refactor complete. CI updated to skip BATS pending subtree pull.
- **Branch protection** — pyjenkinsapi main now has 1 required review + enforce_admins enabled. rigor-cli enforce_admins restored.
- **Next branch** — rigor-cli-v0.1.6 created at `7fc2017`, retrospective added.

## Next Steps
- Pull rigor-cli subtree into pyjenkinsapi to activate ai-* symlinks.
- Phase 4: Full integration tests with various consumer repos.
