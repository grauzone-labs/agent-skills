---
name: implement-work-item
description: Implement one tracker work item end to end, from its dependency gate through its merged pull request, on GitHub, Azure DevOps, or another tracker and pull request system. Invoke as `$implement-work-item` followed by the work item ID.
license: MIT
disable-model-invocation: true
metadata:
  author: "Sascha Grau"
  version: "1.0.0"
  category: "engineering"
---

# Implement a work item

Take one work item from the tracker to a merged pull request against the target branch. The user supplies the work item ID and two gos: one that opens the pull request and one that merges it. Derive scope and context from the tracker.

## Input and operating rules

- Accept exactly one work item ID in the tracker's form: an issue number on GitHub, a work item ID on Azure DevOps, a key such as `ABC-123` elsewhere. If it is missing, malformed, or unknown to the tracker, report that and stop.
- Follow `AGENTS.md` and the `model-routing` skill throughout, including each delegated task. Parallelize independent work across agents when possible; give each agent its routed model and a separate set of files.
- Make routine, reversible choices yourself. Ask only about a genuine blocker or consequential decision, while continuing independent work. Explain the concrete blocker and what would clear it.
- Preserve unrelated work. Resetting or deleting any other branch requires the user's explicit authorization.
- Report to the user in the language they write in.

## Systems and repository rules

This skill names each operation by what it achieves; the repository says how to perform it.

- **Repository rules come first.** Before reading or acting on work items, read `AGENTS.md` and the tracker documentation it points to, commonly `docs/agents/issue-tracker.md`. Their work item types, dependency contract, implementation operations, branch and commit conventions, status rules, and required reviews apply to every step below.
- **Where they are silent,** identify the tracker and the pull request system from the `origin` remote URL and use that system's CLI: `gh` for GitHub, `az boards` and `az repos` for Azure DevOps. Read the CLI's help for the exact call. If a system cannot be identified or reached, report that and stop.
- **Target branch:** the repository's default branch, unless repository rules name another.

| This skill | GitHub | Azure DevOps |
| --- | --- | --- |
| Work item ID | Issue number | Work item ID |
| Parent chain | Parent issues through sub-issues | Parent links |
| Blocking dependency | Native `blocked_by` issue dependency | Predecessor link |
| Closing link | `Closes #<id>` in the pull request body | Work item linked to the pull request and completed with it |
| Required checks | Required status checks | Branch policies |
| Rebase merge | Rebase and merge | Rebase and fast-forward |

## 1. Load the authorized context

Fetch the work item and its comments, follow its parent chain to the top, and read those items. Read the domain documentation that repository rules point to, commonly `CONTEXT.md` and the ADRs through `docs/agents/domain.md`, before exploring domain behavior. Derive the acceptance criteria, authorized behavior, and agreed public test seams from these sources.

If the work item is a container whose work lives in its children, such as an Epic or a Feature, report that and stop.

## 2. Dependency start gate

Complete this gate before creating or switching branches and before changing code.

Proceed only if every blocking dependency of the work item, including closed ones, has its implementation merged into the target branch. Enumerate the actual dependency records; a count of open blockers alone cannot rule out manually closed blockers. Where the tracker keeps no dependency records, the blockers named in the work item and its parents are the records. Verify each dependency's merged implementation through its pull request or commit. A closed work item by itself is not evidence of a merge. Missing dependency data, an API error, or an unverifiable merge fails the gate. Report the blocker or failed check and stop before branch or code work.

## 3. Branch and review base

Fetch the remote and name the work branch by the repository's convention; without one, use `feature/<work-item-id>-<short-english-slug>`.

- On a fresh start, create the branch from the up-to-date target branch; never base it on an unmerged work branch.
- On resume, reuse the existing work branch and its recorded review base.
- Keep parent membership in the tracker; do not create or use a branch per parent item.
- Before the first change, record the starting commit as the original review base. Keep it on resume. If the target branch advances later, record the new base separately as the current review base and retain the original.
- Do not disturb unrelated work in the worktree or other branches.

## 4. Implement test-first

Implement all authorized behavior in narrow slices, using the `tdd` skill for testable work. At the agreed public seams, first demonstrate the expected behavior with a failing test, then implement it and run focused checks. Do not add behavior beyond the work item and its parents.

Make one verified commit per deliverable unless a different granularity makes review clearer. Commit review corrections separately. Follow the repository's commit convention and reference the work item in each commit message in the form the tracker links, `#<id>` on GitHub and Azure DevOps.

## 5. Sync the work branch

This step applies while the work item has no pull request; an open pull request is synced once, at the merge gate in step 11.

Fetch the target branch before publishing. If it moved, rebase the work branch onto it, resolve every conflict, move the current review base to that commit, and keep the original review base recorded. Publish a rebased branch with `--force-with-lease` against the remote tip recorded for this work branch. If the remote tip changed unexpectedly, stop and report the conflict; do not overwrite it.

## 6. Verify

Run the checks affected by the change and the repository's full local test suite. Where CI runs on branch pushes, verify it on the pushed work branch, before a pull request exists; where it runs only on pull requests, verify it in step 9. Report checks that could not be run and their current status; completion requires every required check to pass on the final head.

## 7. Review both axes

Use the `code-review` skill on the final diff from the current review base. Review in two distinct passes:

- **Standards:** repository conventions, `AGENTS.md`, relevant ADRs, and domain language.
- **Specification:** the work item's acceptance criteria and its parents' scope.

Fix every actionable finding, rerun affected checks and the full local test suite, and commit corrections separately.

## 8. Pull request gate

The user decides when the pull request opens, which keeps the number of open pull requests small. An automated reviewer such as CodeRabbit reviews every push to an open pull request, so all syncing with the target branch happens before one exists.

Push the verified, reviewed work branch. Report that the work item is ready, with the branch, its head commit, the check results, and the pull requests currently open against the target branch. Then stop and wait for the user's go.

On the go, fetch the target branch. If it moved, repeat step 5 and step 6 on the rebased branch, and repeat step 7 for every file in which the rebase resolved a conflict. This gate is passed when the pushed head contains the current target branch and every check that runs on branch pushes is green on it.

## 9. Pull request and required reviews

Use the `pr` skill to open one pull request to the target branch, carrying the closing link for the work item. Link it to the thread with the host's tool when available. Follow the status rules in the tracker documentation.

Stay on the pull request until every required check is green and every reviewer that repository rules require, automated or human, has reviewed the head commit without open findings. Fix every valid finding or reply with the reason for leaving it, push the update, and wait for the review of the new head.

Leave the open pull request as it is while the target branch advances, also when the pull request system reports a conflict with it. Step 11 syncs it once, at merge time, so syncing costs at most one further review round.

## 10. Completion report

Report once the pull request head is green, both review axes are clean, and the required reviews have no open findings on that head. Report the pull request, commits, verification results, review status, and known limits or open points. Then stop and wait for the user's go to merge.

## 11. Merge gate

The user decides when the pull request merges. On the go:

1. **Sync if needed.** Read whether the pull request can merge. If the pull request system reports a conflict with the target branch, rebase the work branch as in step 5, repeat step 6, and repeat step 7 for every file in which the rebase resolved a conflict. Then stay on the pull request as in step 9 until the new head is green and reviewed without open findings. A pull request without a conflict merges as it is, even when the target branch has advanced.
2. **Merge.** Complete the pull request with the system's rebase merge and delete the work branch; on GitHub, `gh pr merge <pr-number> --rebase --delete-branch`. The go authorizes deleting this work item's branch only. If the local branch stays because this worktree has it checked out, leave it and say so. If the system or repository rules do not allow a rebase merge, report that and ask which merge method to use. If the merge is refused for another reason, report the system's message and stop.
3. **Confirm.** Check that the pull request is merged, the remote work branch is gone, and the work item has reached its final state under the tracker's status rules; set that state where the merge did not. Report the commits now on the target branch, the deleted branch, and the work item's state.

The work is complete when the pull request is merged, the remote work branch is deleted, and the work item is in its final state.
