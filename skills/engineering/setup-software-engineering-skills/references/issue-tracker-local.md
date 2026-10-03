# Issue tracker: local Markdown

Issues and specs for this repo live as markdown files in `.scratch/`.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The spec is `.scratch/<feature-slug>/spec.md`
- Implementation issues are one file per ticket at `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` - never a single combined tickets file
- A triaged issue records `Category: bug | enhancement` and `Triage: <state role>` near the top. When `docs/agents/triage-labels.md` exists, use its mapped role strings.
- Comments and conversation history append to the bottom of the file under a `## Comments` heading

## When a skill says "publish to the issue tracker"

Create a new file under `.scratch/<feature-slug>/` (creating the directory if needed).

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.

## Wayfinding operations

Used by the `wayfinder` skill. The **map** is a file with one **child** file per ticket.

- **Map**: `.scratch/<effort>/map.md`. Use the canonical map body from the `wayfinder` skill.
- **Child ticket**: `.scratch/<effort>/issues/NN-<slug>.md`, numbered consecutively from `01` in breadth-first discovery order, with the question in the body. The numeric prefix is the authoritative Wayfinding order. A `Type:` line records the ticket type (`research`/`prototype`/`grilling`/`task`); a `Wayfinding:` line records `open`/`claimed`/`resolved`.
- **Blocking**: a `Blocked by: NN, NN` line near the top. A ticket is unblocked when every file it lists has `Wayfinding: resolved`.
- **Frontier**: scan `.scratch/<effort>/issues/` for tickets with `Wayfinding: open` that are unblocked; the lowest numeric prefix wins.
- **Claim**: set `Wayfinding: claimed` and save before any work.
- **Resolve**: append the answer under an `## Answer` heading, set `Wayfinding: resolved`, then append a context pointer (artifact + link) to the map's Decisions so far in `map.md`.
