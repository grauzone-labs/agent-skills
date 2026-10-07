---
name: to-spec
description: Creates and publishes an implementation-ready spec from the current conversation. Use when a discussed feature or change is settled enough to write up and publish to the issue tracker; `to-tickets` owns breaking approved work into implementation tickets.
compatibility: Requires file access for a local Markdown tracker, or the CLI and network access specified in docs/agents/issue-tracker.md for a remote tracker.
license: MIT
disable-model-invocation: true
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "engineering"
---

# To spec

A gap that blocks implementation becomes an open question in the spec; the work continues from the available evidence.

## Process

### 1. Ground the spec

Read `docs/agents/issue-tracker.md`, and `docs/agents/triage-labels.md` when it exists. Read the established conversation and every user-provided source. Follow the domain contract in `docs/agents/domain.md` when it exists. Otherwise, use the root `CONTEXT-MAP.md` to locate affected contexts, or the root `CONTEXT.md` for a single context, and read the relevant glossaries and system-wide and context-specific ADRs. Explore the relevant code only as far as needed to establish current behavior, conventions, and comparable tests.

**Complete when:** the tracker contract is read or confirmed absent, and the spec's terminology, affected behavior, prior architectural decisions, and relevant test prior art are evidenced or explicitly absent.

### 2. Choose the test seams

For every intended externally observable behavior, select the highest existing test seam that can prove it. Prefer one seam; when no existing seam is sufficient, propose the minimal new seam at the highest viable boundary. These seams fill the Testing Decisions section.

**Complete when:** every intended behavior has a testable seam, each proposed new seam is justified, and each lower-level seam proves a distinct behavior unavailable at the higher seam.

### 3. Write and publish

Write the spec using the [spec template](#spec-template). Classify the issue as `bug` when the conversation establishes a defect, otherwise `enhancement`. Apply the configured category role: the mapping in `docs/agents/triage-labels.md` when it exists, otherwise the tracker contract's native category field when it defines one, otherwise none.

Set the readiness state by the Open questions section:

- **No implementation blocker:** apply the ready-for-agent state: the mapped role when the mapping exists, otherwise the tracker contract's native ready state when it defines one, otherwise none.
- **A blocker remains:** publish with the tracker contract's unresolved state, or without readiness metadata when the contract has no state model, and state the promotion condition in the report.

When the tracker contract is absent or does not describe publication, return the spec in the reply instead of publishing, and report that repository setup blocks publication and that the `setup-software-engineering-skills` skill establishes the contract.

After publishing, read the saved spec and its metadata back from the tracker; fix any mismatch with the draft and read back again. When publication fails, return the full spec in the reply and report the failed operation and its observed cause on the Locator line.

Report with the template below.

```markdown
## Spec: <title>

- Locator: <identifier, URL, or local spec path; "unpublished: repository setup blocks publication" when not published>
- Category: <bug|enhancement, with the applied role or field>
- State: <ready-for-agent|unresolved|none, with the applied role or field>
- Open questions: <one line each, or "none">
- Promotion condition: <what resolves the blocker, or "none">
```

**Complete when:** the saved spec matches the draft on read-back, or the spec is returned in the reply with the setup or failure report; category reflects defect versus enhancement and readiness reflects whether implementation is blocked; and the report is given with the stable locator.

## Spec template

```markdown
## Problem Statement

The problem the user faces, from the user's perspective.

## Solution

The intended outcome, from the user's perspective.

## User Stories

A numbered list of distinct user stories covering every established actor, lifecycle state, permission boundary, failure or recovery path, and externally observable outcome.

1. As an <actor>, I want a <feature>, so that <benefit>.

## Acceptance Criteria

A checkable list of observable outcomes that prove the solution works, including relevant negative cases and boundary conditions.

- [ ] Criterion 1
- [ ] Criterion 2

## Implementation Decisions

Describe decisions as modules, interfaces, and contracts. Code appears only as a decision-rich excerpt from a prototype, marked as prototype-derived, with the executable prototype linked as its primary source.

### Confirmed decisions

Decisions established by the conversation, including affected modules, interfaces, architectural choices, schema changes, API contracts, and specific interactions.

### Repository-aligned proposals

Necessary implementation details inferred from established repository conventions or code evidence. State the evidence for each proposal.

### Open questions

Only decisions whose absence blocks implementation. State the decision needed and its impact.

## Testing Decisions

For each acceptance criterion, state the externally observable behavior, the selected test seam, and comparable test prior art.

## Out of Scope

Things the spec intentionally excludes.

## Further Notes

Relevant context that does not alter the implementation contract.
```
