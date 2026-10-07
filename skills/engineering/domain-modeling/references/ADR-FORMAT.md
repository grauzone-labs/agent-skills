# ADR format

## Decide whether an ADR qualifies

Create an ADR only when all three conditions hold:

1. **Hard to reverse** - changing the decision later has meaningful cost.
2. **Surprising without context** - a future reader will wonder why the code takes this shape.
3. **A real trade-off** - genuine alternatives existed and one was chosen for specific reasons.

Typical qualifying choices include architectural shape, context integration patterns, technology choices with lock-in, ownership boundaries, deliberate deviations from the obvious path, non-code constraints, and non-obvious rejected alternatives.

When a condition cannot be judged from the evidence, ask the user for the missing fact and report the decision as unresolved. When a condition fails, report which one.

## Place and number

Write the ADR in the ADR directory identified in step 1 for the decision's scope, numbered sequentially within that directory: `0001-slug.md`, `0002-slug.md`, and so on.

## Template

```md
# {Short title of the decision}

{1-3 sentences: what is the context, what was decided, and why?}
```

## Optional sections

Include additional material only when it helps a future reader understand the decision:

- **Status** frontmatter: `proposed`, `accepted`, `deprecated`, or `superseded by 0002-slug.md` (the superseding ADR's filename).
- **Considered options** when rejected alternatives are worth remembering.
- **Consequences** when non-obvious downstream effects need to be called out.

**Complete when:** the ADR meets all three conditions, sits in the identified directory with the next local number, and records the decision and its rationale without unsupported detail.
