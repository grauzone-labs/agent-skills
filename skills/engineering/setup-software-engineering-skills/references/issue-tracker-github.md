# Issue tracker: GitHub

Issues and specs for this repo live as GitHub issues. Use the `gh` CLI for all operations.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --comments`, filtering comments by `jq` and also fetching labels.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` with appropriate `--label` and `--state` filters.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

Infer the repo from `git remote -v` - `gh` does this automatically when run inside a clone.

## Implementation operations

Used by the `implement-work-item` skill. The work item ID is the issue number. During setup, record the target branch and the merge methods the repository and its rulesets allow (`gh api repos/<owner>/<repo> --jq '{allow_rebase_merge,allow_squash_merge,allow_merge_commit}'`).

- **Blocking dependencies**: `gh api repos/<owner>/<repo>/issues/<n>/dependencies/blocked_by --jq '[.[] | {number, state}]'` lists every blocker, including closed ones. `issue_dependencies_summary.blocked_by` on the issue counts open blockers only.
- **Parent chain**: `gh api repos/<owner>/<repo>/issues/<n>/parent` returns the parent issue; repeat it on each parent until the call returns 404.
- **Merged implementation of a dependency**: read the pull requests that closed the blocker and whether each is merged into the target branch:

  ```sh
  gh api graphql -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){issue(number:$n){state stateReason closedByPullRequestsReferences(first:10,includeClosedPrs:true){nodes{number merged baseRefName mergeCommit{oid}}}}}}' \
    -f o=<owner> -f r=<repo> -F n=<n> --jq .data.repository.issue
  ```

  The implementation is merged when a node has `merged: true` and `baseRefName` is the target branch. A closed blocker without such a pull request is unverified.
- **Commit references**: `#<n>` in a commit message links the commit to the issue.
- **List open pull requests**: `gh pr list --base <target-branch> --state open`.
- **Open a pull request**: `gh pr create --base <target-branch> --head <work-branch> --title "..." --body-file <file>`, with `Closes #<n>` in the body as the closing link.
- **Read checks and reviews**: `gh pr checks <pr> --required` lists the required status checks; add `--watch` to wait for them. `gh pr view <pr> --json reviewDecision,reviews` returns the review state, and `gh api repos/<owner>/<repo>/pulls/<pr>/comments` the review comments.
- **Read the conflict state**: `gh pr view <pr> --json mergeable,mergeStateStatus`. `MERGEABLE` means the pull request can merge, `CONFLICTING` means the work branch needs a sync, and `UNKNOWN` means GitHub is still computing; read it again.
- **Complete with a rebase merge**: `gh pr merge <pr> --rebase --delete-branch --match-head-commit <reviewed-head-sha>`. `--match-head-commit` refuses the merge when the head moved after the review. `--delete-branch` deletes the remote branch and the local one; in a worktree that has the branch checked out, the local deletion can fail after the merge succeeded.
- **Confirm the result**: `gh pr view <pr> --json state,mergedAt` shows `MERGED`, `git ls-remote --heads origin <work-branch>` returns nothing, and the GraphQL query above shows the issue `CLOSED` with `stateReason` `COMPLETED`.

## Pull requests as a triage surface

**PRs as a request surface: no.** _(Set to `yes` if this repo treats external PRs as feature requests; the `triage` skill reads this flag.)_

When set to `yes`, PRs run through the same labels and states as issues, using the `gh pr` equivalents:

- **Read a PR**: `gh pr view <number> --comments` and `gh pr diff <number>` for the diff.
- **List external PRs for triage**: `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments` then keep only `authorAssociation` of `CONTRIBUTOR`, `FIRST_TIME_CONTRIBUTOR`, or `NONE` (drop `OWNER`/`MEMBER`/`COLLABORATOR`).
- **Comment / label / close**: `gh pr comment`, `gh pr edit --add-label`/`--remove-label`, `gh pr close`.

GitHub shares one number space across issues and PRs, so a bare `#42` may be either - resolve with `gh pr view 42` and fall back to `gh issue view 42`.

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Run `gh issue view <number> --comments`.

## Wayfinding operations

Used by the `wayfinder` skill. The **map** is a single issue with **child** issues as tickets.

- **Map**: a single issue labelled `wayfinder:map`, with the canonical map body from the `wayfinder` skill. `gh issue create --label wayfinder:map`.
- **Child ticket**: an issue linked to the map as a GitHub sub-issue (`gh api` on the sub-issues endpoint). Put `Wayfinding order: <NN>` at the top of every child body, assigning consecutive numbers in breadth-first discovery order. Where sub-issues aren't enabled, put `Part of #<map>` immediately above that line; this marker is the fallback child relationship. Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Once claimed, the ticket is assigned to the driving dev.
- **Blocking**: GitHub's **native issue dependencies** - the canonical, UI-visible representation. Add an edge with `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`, where `<blocker-db-id>` is the blocker's numeric **database id** (`gh api repos/<owner>/<repo>/issues/<n> --jq .id`, _not_ the `#number` or `node_id`). GitHub reports `issue_dependencies_summary.blocked_by` (open blockers only - the live gate). Where dependencies aren't available, fall back to a `Blocked by: #<n>, #<n>` line at the top of the child body. A ticket is unblocked when every blocker is closed.
- **Frontier query**: list the map's open sub-issues. Where sub-issues aren't enabled, search open issues for the exact top-of-body `Part of #<map>` marker (for example, `gh issue list --state open --search '"Part of #<map>" in:body'`) and retain only exact matches. Drop any ticket with an open blocker (`issue_dependencies_summary.blocked_by > 0`, or an open issue in the `Blocked by` line) or an assignee, then sort by `Wayfinding order` ascending. The lowest number wins.
- **Claim**: `gh issue edit <n> --add-assignee @me` - the session's first write.
- **Resolve**: `gh issue comment <n> --body "<answer>"`, then `gh issue close <n>`, then append a context pointer (artifact + link) to the map's Decisions so far.
