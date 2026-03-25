# Issue Log: Copilot PR #4 Review Findings

**Date:** 2026-03-25
**PR:** #4 — v0.1.1 milestone close-out
**Reviewer:** Copilot

---

## Finding 1 — README releases table links to unreleased tag

**File:** `README.md` line 201
**What Copilot flagged:** The releases table linked `v0.1.1` to `https://github.com/wilddog64/rigor-cli/releases/tag/v0.1.1`, which does not exist until after merge and tagging. Link would 404 while PR is open.

**Fix applied (`33c2926`):**

Before:
```markdown
| [v0.1.1](https://github.com/wilddog64/rigor-cli/releases/tag/v0.1.1) | 2026-03-24 | ... |
```

After:
```markdown
| v0.1.1 _(unreleased)_ | 2026-03-24 | ... |
```

**Root cause:** Release table entry was written proactively before the tag existed.

**Process note:** Add to PR template — releases table rows must not include tag links until the tag is created (i.e., post-merge). Use plain text `_(unreleased)_` until `/post-merge` runs.

---

## Finding 2 — CHANGE.md marks v0.1.1 as released while PR still open

**File:** `CHANGE.md` line 4
**What Copilot flagged:** Heading `## [v0.1.1] — 2026-03-24` claims the version is already released. Tag/release doesn't exist until merge.

**Fix applied (`33c2926`):**

Before:
```markdown
## [v0.1.1] — 2026-03-24
```

After:
```markdown
## [Unreleased] — v0.1.1
```

**Root cause:** CHANGE.md was finalized with the version number and date before the tag was created.

**Process note:** CHANGE.md must keep `[Unreleased]` heading while the PR is open. Finalize to `[vX.Y.Z] — YYYY-MM-DD` only after merge, as part of `/post-merge` tagging step.
