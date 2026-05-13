# Progress — rigor-cli

## v0.1.0 Track (branch: `main`)

- [x] **Repo skeleton** — COMPLETE.
- [x] **rigor audit** — COMPLETE.
- [x] **rigor lint** — COMPLETE.
- [x] **rigor review** — COMPLETE.
- [x] **ai-bootstrap / ai-lint / ai-review helpers** — COMPLETE (`71b3c84`).
- [x] **Release v0.1.5** — SHIPPED 2026-05-08 (tag v0.1.5, release published).

## Completed (v0.1.5)
- [x] Create `bin/ai-bootstrap`
- [x] Create `bin/ai-lint`
- [x] Create `bin/ai-review` (configurable prompt)
- [x] BATS tests coverage for helpers
- [x] pyjenkinsapi symlink refactor (SHA: `65621642`)
- [x] Retrospective added to rigor-cli-v0.1.6 (commit: `cca6240`)

## Completed (v0.1.6)
- [x] Add `bin/ai-triage-pod` for Kubernetes pod triage with optional stdin/file context (`4f47a2c`)
- [x] Document `ai-triage-pod` in `docs/howto/ai-triage-pod.md` and `docs/howto/use-ai-helpers.md`
- [x] Add BATS coverage for the new helper

## Post-Merge Housekeeping (2026-05-08)
- [x] Branch protection pyjenkinsapi main: 1 review + enforce_admins
- [x] enforce_admins restored on rigor-cli main
- [x] v0.1.5 tag pushed, GitHub release created
- [x] rigor-cli-v0.1.6 branch created
- [x] docs/next-improvements branch created (pyjenkinsapi)
- [x] Retrospectives committed to both next branches
