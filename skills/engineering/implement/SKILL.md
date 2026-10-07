---
name: implement
description: Implements a spec or ticket in narrow, verified slices with tests, a closing review, and proven acceptance criteria. Use when an approved spec or ticket is ready to build on the current branch; `implement-work-item` owns a tracker work item ID taken to a merged pull request.
compatibility: Requires git, a project test runner, a host that can run sub-agents, and the tdd and two-axis-review skills of this collection. Tracker tickets require network access and an authenticated tracker tool.
license: MIT
disable-model-invocation: true
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "engineering"
---

# Implement

1. Read the spec or ticket and record the current `HEAD` commit as the review fixed point. Your first message to the user, sent before any tool call that changes a file, is the line `Behavior: <intended behavior>; Seams: <the test seams it names, or "unspecified">; Fixed point: <SHA>`. When the spec names no seam, propose one in that message and end your turn; resume at step 2 once the user agrees to a seam.
2. Use the `tdd` skill for every testable slice at the agreed seams. Keep feedback tight: run the relevant type checks and the focused tests after each slice.
3. Commit the verified implementation on the current branch, then use the `two-axis-review` skill with the recorded fixed point and the spec path as its arguments. For an inline or tracker ticket, save its text to a temporary file outside the worktree and pass that path. The review is done when both review reports are in your context: wait for both sub-agents to finish and keep the turn open while they run.
4. Run the full suite. Fix every actionable finding, rerun the affected checks and the full suite until both pass, then commit the corrections separately. If a check or the review cannot run, report the blocked operation, its cause, and the work remaining.
5. Only after step 4 passes, for every acceptance criterion of the spec or ticket, name the evidence on the final commit that proves it: the test, the check, or the observed behavior. Where the criteria are a checklist, tick the proven criterion in the spec file or in the ticket on the tracker; a criterion without evidence stays unticked and is reported as open with its missing evidence.

Report with the template below.

```markdown
## Implemented: <spec or ticket>

- Commits: <one line per commit>
- Checks: <full suite result and each other check run>
- Review: <clean|findings fixed>
- Acceptance criteria: <proven>/<total> proven
  - <criterion>: <proven: the test, check, or observed behavior | open: the missing evidence>
```

**Complete when:** every specified behavior is implemented and verified at its agreed seam, the full suite passes, every actionable review finding is fixed, every acceptance criterion is proven with its evidence named or listed as open with its missing evidence, every proven checklist criterion is ticked, all resulting work is committed, and the report is given.
