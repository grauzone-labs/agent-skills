# Wide refactors

Use this sequence only for one mechanical change with a codebase-wide **blast radius**: a rename, retype, or shared-contract change whose intermediate state cannot land as independently green tracer bullets.

## Expand–migrate–contract

1. **Expand** — add the new form beside the old form, keeping current callers and CI green.
2. **Migrate** — move callers in batches sized by blast radius, such as one package or directory at a time. Each batch is blocked by the expand ticket and remains green independently.
3. **Contract** — remove the old form only after every migrate ticket has completed. This ticket is blocked by every migration ticket.

When migration batches cannot remain green independently, keep the same dependency sequence on an integration branch. Make a final **integrate and verify** ticket depend on every batch; it owns the end-to-end green verification.

**Complete when:** the ticket graph makes the compatibility path explicit, every migration batch has a bounded blast radius, and the contract ticket cannot start while an old-form caller remains.
