---
name: domain-modeling
description: Builds and sharpens a project's domain model. Use when the user wants to pin down domain terminology, a glossary, or a ubiquitous language, record an architectural decision or ADR, or when another skill needs to maintain the domain model.
license: MIT
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "engineering"
---

# Domain modeling

## 1. Establish the document layout

When `docs/agents/domain.md` exists, read it and follow it: it is the repository-specific document layout and overrides the defaults below, including the formats in the references.

Otherwise select the documents from these defaults:

- `CONTEXT-MAP.md` exists at the repository root: read it to select every context whose terms or relationships the topic affects. Ask the user when the owning context is unclear.
- Only a root `CONTEXT.md` exists: use it.
- Neither exists: a root `CONTEXT.md` is created when the first term is resolved.
- ADRs live in `docs/adr/` for system-wide decisions and in `<context>/docs/adr/` beside a context's `CONTEXT.md` for context-specific decisions. A directory is created with its first ADR.

**Complete when:** every selected `CONTEXT.md` and ADR directory is identified, each as present or to be created.

## 2. Read the current model and evidence

Read each selected `CONTEXT.md`, the ADRs that affect the topic, and the relevant code before proposing terminology or a decision. Treat the current glossary as the starting language, not a constraint that prevents correcting it.

**Complete when:** existing terminology, prior decisions, and code behavior relevant to the discussion are known or explicitly absent.

## 3. Sharpen the model

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in the owning `CONTEXT.md`, surface the conflict and ask which meaning is intended.

### Sharpen fuzzy language

When a term is vague or overloaded, propose a precise canonical term. Test domain relationships with concrete scenarios that force their boundaries to become explicit.

### Cross-reference with code

When the user states how something works, check whether the code agrees. Surface contradictions for resolution rather than silently preferring either source.

**Complete when:** every term or relationship settled in the discussion has one unambiguous meaning and any code contradiction is resolved or explicit.

## 4. Capture settled knowledge

When a term is resolved, update its owning `CONTEXT.md` immediately in the glossary format of [CONTEXT-FORMAT.md](references/CONTEXT-FORMAT.md); when the term crosses contexts, record the relationship in `CONTEXT-MAP.md` as that file shows.

When an architectural choice is settled, test it against the qualifying conditions in [ADR-FORMAT.md](references/ADR-FORMAT.md) and record the qualifying ones in the ADR directory as that file prescribes.

Re-read each saved document against the settled items and its format, and fix every omission or misplaced entry.

**Complete when:** the owning `CONTEXT.md` files reflect every settled term, `CONTEXT-MAP.md` every settled cross-context relationship, each qualifying architectural decision is recorded in its ADR directory, the re-read found nothing left to fix, and unresolved terms remain explicit.

## Delivery evidence

Report in this form:

```md
## Domain modeling

- Documents: `<path of the selected CONTEXT.md>`, ADRs in `<directory>`
- Terms added or changed: <term - one-line definition>, or none
- Decisions recorded: <ADR number and title>, or none
- Code evidence checked: <files or symbols>, or none
- Unresolved: <open terms, ownership questions, or contradictions>, or none
```
