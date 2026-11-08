# Pull requests

Continue using the calling workflow's tracker/PR CLI or connector for creating PRs, reading checks, posting comments, and merging. T3 tracking complements those operations; it does not replace their authorization or acceptance gates.

1. **Register.** Immediately after creating a PR or starting work on an existing one, call `t3-code:link_pull_request` with its full URL. For a stack, link each layer. Idempotent linking is safe. On failure, report the failed registration and keep the existing URL; do not recreate the PR or claim it is linked. A body-only draft creates no PR and needs no registration.
2. **Monitor when requested or required by the active workflow.** Handle existing comments first, then the parent thread calls `t3-code:watch_pull_request` and ends the turn. The app wakes the thread on check/review/conflict changes; do not poll, sleep, or launch a watcher. A subagent returns the URL and monitoring need to its parent because subagents cannot watch. A wake is news: re-check readiness and the reviewed head before deciding the next authorized action; it grants no merge permission.
3. **Hand back.** Call `t3-code:unwatch_pull_request` before handing control to the user so the thread returns to their inbox. Before finishing PR work, call `t3-code:list_thread_pull_requests` and register any PR from this work that is missing. Preserve the calling workflow's opening and merge gates.

When a capability is confirmed absent/unsupported, use the calling workflow's original PR operations and monitoring path. Report other operation failures with their observed error; permission or authentication failure is not a reason to bypass T3's access rules.

**Complete when:** the work's PRs are registered or their registration failures are explicit, monitoring ownership is correct, and any active watch ends at handoff.
