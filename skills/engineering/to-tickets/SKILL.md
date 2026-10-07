---
name: to-tickets
description: Turns an approved plan, spec, or conversation into dependency-aware implementation tickets and publishes them through the repository's configured tracker. Use when approved work needs to become trackable tickets; `to-spec` writes the spec itself.
compatibility: Requires file access for a local Markdown tracker, or the authenticated CLI and network access specified in docs/agents/issue-tracker.md for a remote tracker; remote sources also require network access.
license: MIT
disable-model-invocation: true
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "engineering"
---

# To tickets

## Process

Record the five steps below in the host's task list tool, one task per step, before step 1, and mark each done as its completion criterion holds.

### 1. Establish the contracts

Read `docs/agents/issue-tracker.md` before drafting or publishing; it is the source of truth for creation, metadata, hierarchy, and dependency operations. When it exists, also read `docs/agents/triage-labels.md` before applying the ready-for-agent state, and read `docs/agents/domain.md` before using domain vocabulary or locating ADRs.

If `docs/agents/issue-tracker.md` is absent or does not describe how to create tickets, stop and report that repository setup blocks ticketing and that the `setup-software-engineering-skills` skill establishes the contract.

When the user supplies a spec path, issue reference, or URL, fetch its full body and comments. Treat an existing issue as a **source** unless the user explicitly asks to make it a parent; preserve the content and metadata of the source and every parent, and add only the requested parent relationship.

**Complete when:** the tracker rules, applicable metadata rules, relevant domain references, and complete source material are available.

### 2. Ground the breakdown

Explore the affected code when the available source does not already establish its current behavior, boundaries, and terminology. Use the domain vocabulary and applicable ADRs that `docs/agents/domain.md` names; when that file is absent, use the root `CONTEXT-MAP.md` to locate affected contexts, or the root `CONTEXT.md` for a single context, and read the relevant glossaries and ADRs.

Identify preparatory refactoring only when it makes a later tracer bullet independently buildable and verifiable.

**Complete when:** every proposed ticket names a user-visible outcome or a verifiable technical outcome in the project’s vocabulary, and any necessary preparatory work names the tracer bullet it enables.

### 3. Draft tracer bullets

- Each **tracer-bullet** ticket delivers one narrow, complete path through every **affected** layer; a preparatory or wide-refactor ticket instead names the technical outcome it establishes.
- Each ticket is demonstrable or independently verifiable and fits one fresh context window.
- Assign every in-scope outcome to exactly one ticket; acceptance criteria make the outcome checkable.
- Give each ticket its **blocking edges**: only tickets that must complete before this ticket can start.
- Keep the dependency graph acyclic.

When a mechanical change has a codebase-wide **blast radius** and cannot remain green as tracer bullets, load [wide-refactors.md](references/wide-refactors.md) and use its expand–migrate–contract sequence.

**Complete when:** the tickets cover the approved scope exactly once, each has checkable acceptance criteria, and every blocking edge is necessary and acyclic.

### 4. Get approval

Present the proposed breakdown with the template below, one entry per ticket.

```markdown
1. **<Title>**
   - Blocked by: <ticket numbers from this list, or none>
   - Delivers: <the end-to-end behavior or technical outcome it establishes>
   - Acceptance criteria: <the observable conditions that prove it works, one per line>
```

Ask whether the granularity is right, the blocking edges are correct, and any tickets should merge or split. Iterate until the user approves the exact breakdown to publish.

**Complete when:** the user has approved every ticket, acceptance criterion, and blocking edge.

### 5. Publish and verify

1. Create one ticket per approved item in dependency order, so every blocker has an identifier before a blocked ticket refers to it, with the [ticket body](#ticket-body) below.
2. Record each blocking edge with the tracker contract’s dependency operation, including its documented fallback when the native mechanism is unavailable; use the ticket body’s `## Blocked by` section only when the contract documents neither.
3. Apply the ready-for-agent state: take the role name from `docs/agents/triage-labels.md`, or `ready-for-agent` when that file is absent, and write it into the tracker contract’s readiness field (`Triage: <state role>` becomes `Triage: ready-for-agent`) or apply the contract’s native ready state. Publish without a readiness state only when the contract defines neither a readiness field nor a native ready state.
4. Read back every created ticket and compare its title, body, metadata, source reference, and blocking edges with the approved breakdown. Fix every mismatch and read the ticket back again until it matches.

If a tracker operation fails, check the tracker for partial success before retrying so no ticket is created twice; when publishing cannot complete, stop and report the confirmed tickets, the failed operation, and what unblocks it.

Report with the template below.

```markdown
## Published: <n> tickets in <tracker>

- <identifier> <title> — blocked by: <identifiers, or none>
```

**Complete when:** every approved ticket exists in the configured tracker, every blocking edge resolves to the correct ticket, every metadata field the contract names is filled, the published set matches the approved breakdown, and the report is given.

## Ticket body

Use the configured tracker’s required body format, and write every metadata field the contract names (such as `Category:` and `Triage:`) near the top of each ticket, filled in. Where the contract does not supply a body template, use:

```markdown
## What to build

The end-to-end behavior this ticket makes work from the user’s perspective, or the technical outcome it establishes.

## Acceptance criteria

- [ ] Observable condition 1
- [ ] Observable condition 2

## Blocked by

- Blocking ticket identifiers, or `None — can start immediately`; include this section only when step 5 uses the body fallback.

## Source

Reference to the source spec or issue, when applicable.
```

Keep ticket prose decision-rich and durable: describe behavior, contracts, and acceptance criteria rather than current file paths or layer-by-layer implementation. When a prototype produced a decision-rich artifact, include the decision-rich excerpt marked as prototype-derived and link the executable prototype as its primary source.
