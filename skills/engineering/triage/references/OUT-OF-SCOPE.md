# Out-of-scope knowledge base

## Table of contents

- [Directory structure](#directory-structure)
- [File format](#file-format)
- [When to check `.out-of-scope/`](#when-to-check-out-of-scope)
- [When to write to `.out-of-scope/`](#when-to-write-to-out-of-scope)

The `.out-of-scope/` directory in a repo stores persistent records of rejected feature requests: why each was rejected and which issues asked for it, so a repeat request surfaces the prior decision instead of re-litigating it.

## Directory structure

```
.out-of-scope/
├── dark-mode.md
├── plugin-system.md
└── graphql-api.md
```

One file per **concept**, not per issue. Multiple issues requesting the same thing are grouped under one file.

## File format

The file should be written in a relaxed, readable style - more like a short design document than a database entry. Use paragraphs, code samples, and examples to make the reasoning clear and useful to someone encountering it for the first time.

````markdown
# Dark mode

This project does not support dark mode or user-facing theming.

## Why this is out of scope

The rendering pipeline assumes a single color palette defined in
`ThemeConfig`. Supporting multiple themes would require:

- A theme context provider wrapping the entire component tree
- Per-component theme-aware style resolution
- A persistence layer for user theme preferences

This is a significant architectural change that doesn't align with the
project's focus on content authoring. Theming is a concern for downstream
consumers who embed or redistribute the output.

```ts
// The current ThemeConfig interface is not designed for runtime switching:
interface ThemeConfig {
  colors: ColorPalette; // single palette, resolved at build time
  fonts: FontStack;
}
```

## Prior requests

- #42 - "Add dark mode support"
- #87 - "Night theme for accessibility"
- #134 - "Dark theme option"
````

### Naming the file

Use a short, descriptive kebab-case name for the concept: `dark-mode.md`, `plugin-system.md`, `graphql-api.md`.

### Writing the reason

Ground the reason in the maintainer's decision and its evidence:

- Project scope or philosophy ("This project focuses on X; theming is a downstream concern")
- Technical constraints ("Supporting this would require Y, which conflicts with our Z architecture")
- Strategic decisions ("We chose to use A instead of B because...")

Record durable scope decisions here; a temporary circumstance ("we're too busy right now") is a deferral and stays in the triage queue.

## When to check `.out-of-scope/`

For the prior-rejection check in step 1, match by concept, not keyword: "night theme" matches `dark-mode.md`.

If there's a match, surface it to the maintainer: "This is similar to `.out-of-scope/dark-mode.md` - we rejected this before because [reason]. Do you still feel the same way?"

The maintainer may:

- **Confirm** - recommend a rejected `wontfix` in step 3; append the issue to the file's "Prior requests" list and close in step 5
- **Reconsider** - proceed with normal triage; include deleting or updating the file in the recommendation and apply it in step 5; old issues stay closed as historical records
- **Disagree** - the issues are related but distinct, proceed with normal triage

## When to write to `.out-of-scope/`

Only when an **enhancement** (not a bug) is *rejected* as `wontfix`. This applies to enhancement PRs exactly as it does to issues - a rejected PR is recorded here so the same request doesn't return as fresh code.

Something closed as `wontfix` because it's **already implemented** is a built feature, not a rejected one: its closing comment points to where the feature already lives, and this directory stays untouched so the dedup checks only ever match real rejections.

Once the maintainer rejects the request: when a matching file exists, append the new issue to its "Prior requests" list; otherwise create a new file with the concept name, decision, reason, and first prior request. The closing comment links to the file and the mapped `wontfix` label is applied per step 5 of `SKILL.md`.

