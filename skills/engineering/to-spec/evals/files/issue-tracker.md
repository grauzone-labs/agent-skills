# Issue tracker: local Markdown

Issues and specs for this repo live as markdown files in `.scratch/`.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The spec is `.scratch/<feature-slug>/spec.md`
- A triaged issue records `Category: bug | enhancement` and `Triage: <state>` near the top.
- States: `ready-for-agent` when an agent can start implementation; `needs-decision` when a decision blocks it.

## When a skill says "publish to the issue tracker"

Create the file under `.scratch/<feature-slug>/` (creating the directory if needed). The file path is the issue's stable locator.
