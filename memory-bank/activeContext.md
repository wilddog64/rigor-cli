# Active Context — rigor-cli

## Current Branch: `rigor-cli-v0.1.5`

**Status:** Implementation of ai-* helper scripts complete.

## Recent Changes
- **ai-* helpers** — COMPLETE (`71b3c84`). Added `ai-bootstrap`, `ai-lint`, and `ai-review` helper scripts to `bin/`. These scripts wrap `rigor` and provide repo-agnostic linting and review logic.
- **Consumer migration** — COMPLETE (`f0444a5` in pyjenkinsapi). Replaced standalone scripts with symlinks to rigor-cli vendor path.

## Next Steps
- Release v0.1.5 after PR merge.
- Phase 4: Full integration tests with various consumer repos.
