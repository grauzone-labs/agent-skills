# Example service

## Agent skills

### Model routing

At the start of every session, before starting or delegating any task, load and apply the `model-routing` skill when available. Follow its model selection, harness fallback, and session-reuse rules.

### Issue tracker

Issues are tracked in GitHub Issues. Before creating or reading tickets, publishing specifications, changing hierarchy, triaging, wayfinding, or completing work, use the operations and mappings in `docs/agents/issue-tracker.md`.

### Domain docs

Single-context. Before exploring domain behavior or naming domain concepts, use `docs/agents/domain.md`.

## Testing

Run `npm test` before every commit.
