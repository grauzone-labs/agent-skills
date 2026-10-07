# Issue tracker: GitLab

Issues and specs for this repo live as GitLab issues. Use the [`glab`](https://gitlab.com/gitlab-org/cli) CLI for all operations.

## Conventions

- **Create an issue**: `glab issue create --title "..." --description "..."`. Use a heredoc for multi-line descriptions. Pass `--description -` to open an editor.
- **Read an issue**: `glab issue view <number> --comments`. Use `-F json` for machine-readable output.
- **List issues**: `glab issue list -F json` with appropriate `--label` filters.
- **Comment on an issue**: `glab issue note <number> --message "..."`. GitLab calls comments "notes".
- **Apply / remove labels**: `glab issue update <number> --label "..."` / `--unlabel "..."`. Multiple labels can be comma-separated or by repeating the flag.
- **Close**: `glab issue close <number>`. `glab issue close` does not accept a closing comment, so post the explanation first with `glab issue note <number> --message "..."`, then close.
- **Merge requests**: GitLab calls PRs "merge requests". Use `glab mr create`, `glab mr view`, `glab mr note`, etc. - the same shape as `gh pr ...` with `mr` in place of `pr` and `note`/`--message` in place of `comment`/`--body`.

Infer the repo from `git remote -v` - `glab` does this automatically when run inside a clone. In `glab api` paths, `:id` resolves to the current project.

## Implementation operations

Used by the `implement-work-item` skill. The work item ID is the issue IID. The REST routes below are from the GitLab REST reference; the `glab` flags are unverified against a `glab` release - confirm each with `glab <command> --help` during setup and record the version.

- **Target branch**: `<target-branch>`.
- **Merge method**: `<fill in during setup from glab api projects/:id, field merge_method: merge, rebase_merge, or ff>`. GitLab sets the merge strategy per project, not per merge request.
- **Blocking dependencies**: `glab api projects/:id/issues/<n>/links` lists the linked issues with `link_type` and `state`; the blockers are those with `link_type` `is_blocked_by`, including closed ones. Blocking links are a Premium/Ultimate feature; where unavailable, the `Blocked by: #<n>, #<n>` line after the relationship and order markers is the record.
- **Parent chain**: `glab api projects/:id/issues/<n>` returns `epic` when the issue sits in an epic (Premium/Ultimate); the epic is the parent. The chain above an epic and work-item hierarchy are unverified; where neither is available, a `Part of #<n>` line at the top of the description is the record.
- **Merged implementation of a dependency**: `glab api projects/:id/issues/<n>/closed_by` lists the merge requests whose closing pattern references the issue, with `state`, `target_branch`, and `merge_commit_sha`. The implementation is merged when one has `state` `merged` and `target_branch` equal to the target branch. A closed blocker without such a merge request is unverified.
- **Commit references**: `#<n>` in a commit message links the commit to the issue; `Closes #<n>` closes it when the merge request merges into the default branch.
- **Tick an acceptance criterion**: `glab api projects/:id/issues/<n> | jq -r .description > body.md`, change the criterion's `- [ ]` to `- [x]` in `body.md`, then `glab issue update <n> --description "$(cat body.md)"` (REST: `PUT projects/:id/issues/<n>` with `description`). Edit only the checkbox; the rest of the description stays as it was.
- **List open merge requests**: `glab mr list --target-branch <target-branch>` (open is the default state; REST: `projects/:id/merge_requests?state=opened&target_branch=<target-branch>`).
- **Open a merge request**: `glab mr create --source-branch <work-branch> --target-branch <target-branch> --title "..." --description "$(cat <file>)"`, with `Closes #<n>` in the description as the closing link.
- **Read checks and reviews**: `glab api projects/:id/merge_requests/<iid>/pipelines` returns the pipelines, newest first, each with a `status`; `glab ci status --branch <work-branch> --live` waits for the current one. `glab api projects/:id/merge_requests/<iid>/approvals` returns `approved` and `approvals_left`, and `glab api projects/:id/merge_requests/<iid>/discussions` the review comments.
- **Read the conflict state**: `glab api projects/:id/merge_requests/<iid>` returns `has_conflicts` and `detailed_merge_status`. `mergeable` means the merge request can merge, `conflict` means the work branch needs a sync, `checking` or `unchecked` means GitLab is still computing; read it again. Any other value names the policy that blocks the merge.
- **Complete with a rebase merge**: with merge method `ff` or `rebase_merge`, the work branch must already sit on top of the target branch; sync it first. Then `glab mr merge <iid> --sha <reviewed-head-sha> --remove-source-branch` (REST: `PUT projects/:id/merge_requests/<iid>/merge` with `sha` and `should_remove_source_branch`). `sha` refuses the merge when the head moved after the review. With merge method `merge`, GitLab creates a merge commit; record that the rebase merge is unavailable.
- **Confirm the result**: `glab api projects/:id/merge_requests/<iid>` shows `state` `merged`, `git ls-remote --heads origin <work-branch>` returns nothing, and `glab api projects/:id/issues/<n>` shows `state` `closed`.

## Merge requests as a triage surface

**PRs as a request surface: no.** _(Set to `yes` if this repo treats external merge requests as feature requests; the `triage` skill reads this flag.)_

When set to `yes`, MRs run through the same labels and states as issues, using the `glab mr` equivalents:

- **Read an MR**: `glab mr view <number> --comments` and `glab mr diff <number>` for the diff.
- **List external MRs for triage**: `glab mr list -F json`, then keep only MRs whose author is not a project member/owner (a contributor's MR, not a maintainer's in-flight work).
- **Comment / label / close**: `glab mr note`, `glab mr update --label`/`--unlabel`, `glab mr close`.

Unlike GitHub, GitLab numbers issues and MRs separately, so `#42` is unambiguous once you know which surface the maintainer means.

## When a skill says "publish to the issue tracker"

Create a GitLab issue.

## When a skill says "fetch the relevant ticket"

Run `glab issue view <number> --comments`.

## Wayfinding operations

Used by the `wayfinder` skill. The **map** is a single issue with **child** issues as tickets.

- **Map**: a single issue labelled `wayfinder:map`, with the canonical map body from the `wayfinder` skill. `glab issue create --label wayfinder:map`. (On GitLab tiers with native epics, an epic may hold the map instead; a labelled issue works everywhere.)
- **Child ticket**: an issue carrying `Part of #<map>` and `Wayfinding order: <NN>` as the first two lines of its description, with labels `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). This pair is the fallback child relationship: assign consecutive order numbers in breadth-first discovery order. Once claimed, the ticket is assigned to the driving dev.
- **Blocking**: GitLab's **native blocking link** - the canonical, UI-visible representation. Add it with the `/blocked_by #<n>` quick action, posted as a note (`glab issue note <child> --message "/blocked_by #<blocker>"`). Native blocking links are a Premium/Ultimate feature; on the free tier (or where unavailable) fall back to a `Blocked by: #<n>, #<n>` line after the `Part of` and `Wayfinding order` lines. A ticket is unblocked when every blocker is closed.
- **Frontier query**: query project issues whose descriptions contain `Part of #<map>` (for example, `glab api --paginate 'projects/:id/issues?state=opened&search=Part%20of%20%23<map>&in=description'`), then retain only issues whose first line exactly matches the marker. Drop any with an open blocker - a native link with `link_type` `is_blocked_by` to an open issue (`glab api projects/:id/issues/:iid/links`), or an open issue in the `Blocked by` line - or an assignee; sort the remainder by `Wayfinding order` ascending. The lowest number wins.
- **Claim**: `glab issue update <n> --assignee @me` - the session's first write.
- **Resolve**: `glab issue note <n> --message "<answer>"`, then `glab issue close <n>`, then append its index line (the ticket's name linked, then a one-line gist) to the map's Decisions so far.
