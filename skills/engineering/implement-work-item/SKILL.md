---
name: implement-work-item
description: Implements one tracker work item end to end, from its dependency gate through its merged pull request, on GitHub, Azure DevOps, or another tracker and pull request system. Use when the user names a work item ID to implement; `implement` owns a spec or ticket built on the current branch.
compatibility: Requires git, a project test runner for testable work, a host that can run sub-agents, network access to the tracker and pull request system, and the tdd, two-axis-review, pr, and model-routing skills of this collection. Uses gh on GitHub and az with the azure-devops extension on Azure DevOps.
license: MIT
disable-model-invocation: true
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "engineering"
---

# Implement a work item

Take one work item from the tracker to a merged pull request against the target branch. The user supplies the work item ID and two gos: one that opens the pull request and one that merges it. Derive scope and context from the tracker.

## Progress

Record the twelve steps below in the host's task list tool (`update_plan` on Codex, the todo tool on OpenCode), one task per step, before step 1, and mark each task done as its completion criterion holds. Where the host offers no task list tool, copy this checklist into your first response and tick it there instead.

- [ ] 1. [Load the authorized context](#1-load-the-authorized-context)
- [ ] 2. [Dependency start gate](#2-dependency-start-gate)
- [ ] 3. [Branch](#3-branch)
- [ ] 4. [Implement test-first](#4-implement-test-first)
- [ ] 5. [Sync the work branch](#5-sync-the-work-branch)
- [ ] 6. [Verify](#6-verify)
- [ ] 7. [Review both axes](#7-review-both-axes)
- [ ] 8. [Prove the acceptance criteria](#8-prove-the-acceptance-criteria)
- [ ] 9. [Pull request gate](#9-pull-request-gate)
- [ ] 10. [Pull request and required reviews](#10-pull-request-and-required-reviews)
- [ ] 11. [Completion report](#11-completion-report)
- [ ] 12. [Merge gate](#12-merge-gate)

## Input and operating rules

- Accept exactly one work item ID in the tracker's form: an issue number on GitHub, a work item ID on Azure DevOps, a key such as `ABC-123` elsewhere. On resume, the ID is the one already established in the conversation; continue at the pending step. If the ID is missing, malformed, or unknown to the tracker, report that and stop.
- Follow `AGENTS.md` throughout, including each delegated task, and the `model-routing` skill unless the user fixed the model; a user-fixed model stands for the whole work item. Parallelize independent work across agents when possible; give each agent its routed model and a separate set of files.
- Preserve unrelated work in the worktree and on other branches. Resetting or deleting any other branch requires the user's explicit authorization.

When a required operation fails or is unavailable, stop the dependent step and report on one line `Blocked: <operation>; Cause: <error or missing prerequisite>; Needed: <input or action that clears it>`. Resume that step when the prerequisite is available.

## Systems and repository rules

- **Repository rules come first.** Before reading or acting on work items, read `AGENTS.md` and the tracker contract, `docs/agents/issue-tracker.md` when it exists. Their work item types, dependency contract, implementation operations, branch and commit conventions, status rules, and required reviews apply to every step below.
- **Where they are silent,** identify the tracker and the pull request system from the `origin` remote URL and use that system's CLI: `gh` for GitHub, `az boards` and `az repos` for Azure DevOps. Read the CLI's help for the exact call. If a system cannot be identified or reached, report that and stop.
- **Target branch:** the repository's default branch, unless repository rules name another.

| This skill | GitHub | Azure DevOps |
| --- | --- | --- |
| Work item ID | Issue number | Work item ID |
| Parent chain | Parent issues through sub-issues | Parent links |
| Child items | Sub-issues | Child links |
| Blocking dependency | Native `blocked_by` issue dependency | Predecessor link |
| Closing link | `Closes #<id>` in the pull request body | Work item linked to the pull request and completed with it |
| Required checks | Required status checks | Branch policies |
| Rebase merge | Rebase and merge | Rebase and fast-forward |

## 1. Load the authorized context

Fetch the work item, its comments, and its child items, follow its parent chain to the top, and read those items. Read the domain documentation that repository rules point to before exploring domain behavior. Derive the acceptance criteria, authorized behavior, and agreed public seams from these sources.

Present the context in the template below, its heading and every line as written. If the work item is a container whose work lives in its children, such as an Epic or a Feature, say so and stop after the summary.

```markdown
## Work item <ID>: <title>

- Type and state: <type>, <state>
- Parents: <one line per parent from the top down, ID and title, or "none">
- Children: <one line per child, ID, title, and state, or "none">
- Summary: <two or three sentences on what the work item asks for and why>
- Acceptance criteria: <one line each, with the item it comes from and the test, check, or observation that will prove it>
- Public seams: <one line each, with the criterion it tests, or "none: verified by the checks above">
```

Done when every acceptance criterion in the summary names the item it comes from and either the public seam that will test it or the check or observed behavior that will prove it.

## 2. Dependency start gate

Proceed only if every blocking dependency of the work item, including closed ones, has its implementation merged into the target branch. Enumerate the actual dependency records; a count of open blockers alone cannot rule out manually closed blockers. Where the tracker keeps no dependency records, the blockers named in the work item and its parents are the records. Verify each dependency's merged implementation through its pull request or commit. A closed work item by itself is not evidence of a merge. Missing dependency data, an API error, or an unverifiable merge fails the gate.

After the step 1 summary, report `Dependencies: <one line per blocker ID with its merged pull request or commit, or its missing merge, or "none">`. On a failed gate, follow it with the one-line `Blocked: ...; Cause: ...; Needed: ...` report and stop before branch or code work. Done when every dependency record has merge evidence, or a successful lookup confirms none.

## 3. Branch

Fetch the remote and name the work branch by the repository's convention; without one, use `feature/<work-item-id>-<short-english-slug>`.

- On a fresh start, create the branch from the up-to-date target branch only.
- On resume, reuse the existing work branch.
- Parent membership lives in the tracker; the work branch is the only branch this work item creates.

Done when the work branch is checked out.

## 4. Implement test-first

Implement exactly the work item's authorized behavior, within its parents' scope, in narrow slices, using the `tdd` skill for testable work at the agreed public seams.

Make one verified commit per deliverable unless a different granularity makes review clearer. Follow the repository's commit convention and reference the work item in each commit message in the form the tracker links, `#<id>` on GitHub and Azure DevOps.

Done when every acceptance criterion from step 1 is verified by a passing test at its seam or by its named check or observation, and every commit references the work item.

## 5. Sync the work branch

This step applies while the work item has no pull request; an open pull request is synced once, at the merge gate in step 12.

Record the remote tip of the work branch, then fetch the target branch. If it moved, rebase the work branch onto it, resolve every conflict, and publish the rebased branch with `--force-with-lease=<work-branch>:<recorded-tip>`. If the remote tip changed unexpectedly, stop and report the conflict.

A **resync**, when a later step calls for one, is this step followed by step 6 and by step 7 for every file in which the rebase resolved a conflict.

Done when the pushed head contains the current target branch.

## 6. Verify

Run the checks affected by the change and the repository's full local test suite. Where CI runs on branch pushes, verify it on the pushed work branch, before a pull request exists; where it runs only on pull requests, verify it in step 10. Report checks that could not be run and their current status.

Done when every required check that can run before a pull request exists passes on the final head.

## 7. Review both axes

Save the work item and parent context from step 1 to a temporary file outside the worktree. Use the `two-axis-review` skill with that path as its spec and the target branch as its fixed point, in its two passes:

- **Standards:** repository conventions, `AGENTS.md`, relevant ADRs, and domain language.
- **Spec:** the work item's acceptance criteria and its parents' scope.

Fix every actionable finding, commit corrections separately, and repeat step 6 and both passes on the corrected head.

Done when both passes report no actionable finding on the final head.

## 8. Prove the acceptance criteria

For every acceptance criterion from step 1, name the evidence on the final head that proves it: the test, the check, or the observed behavior. Tick the proven criterion in the work item where its criteria are a checklist, following the tracker contract; where it is silent, edit the work item body so the criterion's `- [ ]` becomes `- [x]`. If a tracker update fails, report the error and the pending update separately from the criterion's proof status. A criterion without evidence stays unticked and is reported as open in step 9.

Done when every acceptance criterion is either proven with its evidence named, and ticked where it is a checklist item, or listed as open.

## 9. Pull request gate

The user decides when the pull request opens.

Fetch the target branch; if it moved, resync. Push the verified, reviewed work branch, report with the template below, then stop and wait for the user's go.

```markdown
## Ready: <work item ID> <title>

- Branch: `<work-branch>` at `<head sha>`
- Checks: <each check with its result, or "could not run" and why>
- Review: standards <clean|findings fixed>, spec <clean|findings fixed>
- Acceptance criteria: <proven>/<total> proven, open: <list, or "none">
- Open pull requests against `<target-branch>`: <list, or "none">

Waiting for your go to open the pull request.
```

On the go, fetch the target branch. If it moved, resync. This gate is passed when the pushed head contains the current target branch and every check that runs on branch pushes is green on it.

## 10. Pull request and required reviews

Use the `pr` skill to open one pull request to the target branch, carrying the closing link for the work item. Follow the status rules in the tracker contract.

Stay on the pull request until every required check is green and every reviewer that repository rules require, automated or human, has reviewed the head commit without open findings. Fix every valid finding or reply with the reason for leaving it, push the update, and wait for the review of the new head.

Leave the open pull request as it is while the target branch advances, also when the pull request system reports a conflict with it. Step 12 syncs it once, at merge time.

If that conflict alone keeps a required check or review from running, report it as pending resync in step 11; step 12 clears it before merging. Otherwise, done when the pull request head is green and every required review of that head has no open findings.

## 11. Completion report

Report with the template below once step 10 is done, then stop and wait for the user's go to merge.

```markdown
## Complete: <work item ID> <title>

- Pull request: <link> at `<head sha>`
- Commits: <one line per commit>
- Checks: <each required check with its result, or pending resync>
- Reviews: <each required reviewer with its state on the head, or pending resync>
- Acceptance criteria: <proven>/<total> proven, open: <list, or "none">
- Known limits and open points: <list, or "none">

Waiting for your go to merge.
```

## 12. Merge gate

The user decides when the pull request merges. On the go:

1. **Sync if needed.** Read whether the pull request can merge; re-read while the system still reports the state as unknown. If it reports a conflict with the target branch, resync, then stay on the pull request as in step 10 until the new head is green and reviewed without open findings. A pull request without a conflict merges as it is, even when the target branch has advanced.
2. **Merge.** Complete the pull request with the system's rebase merge, refusing the merge if the head moved after the review, and delete the work branch; on GitHub, `gh pr merge <pr-number> --rebase --delete-branch --match-head-commit <reviewed-head-sha>`. The go authorizes deleting this work item's branch only. If the local branch stays because this worktree has it checked out, leave it and say so. If the system or repository rules do not allow a rebase merge, report that and ask which merge method to use. If the merge is refused for another reason, report the system's message and stop.
3. **Confirm.** Check that the pull request is merged, the remote work branch is gone, and the work item has reached its final state under the tracker's status rules; set that state where the merge did not. Report with the template below.

```markdown
## Merged: <work item ID> <title>

- Pull request: <link>, merged into `<target-branch>`
- Commits now on `<target-branch>`: <one line per commit>
- Remote branch `<work-branch>`: deleted <and local branch deleted|local branch kept, checked out in this worktree>
- Work item: <final state>
```

The work is complete when the pull request is merged, the remote work branch is deleted, and the work item is in its final state.
