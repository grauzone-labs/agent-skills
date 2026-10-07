# Issue tracker

Issues are tracked as Markdown files under `.scratch/`. Fixture copy of the local tracker contract for the `wayfinder` evaluations.

## Wayfinding operations

Used by the `wayfinder` skill. The **map** is a file with one **child** file per ticket.

- **Map**: `.scratch/<effort>/map.md`. Use the canonical map body from the `wayfinder` skill.
- **Child ticket**: `.scratch/<effort>/issues/NN-<slug>.md`, numbered consecutively from `01` in breadth-first discovery order, with the question in the body. The numeric prefix is the authoritative Wayfinding order. A `Type:` line records the ticket type (`research`/`prototype`/`grilling`/`task`); a `Wayfinding:` line records `open`/`claimed`/`resolved`.
- **Blocking**: a `Blocked by: NN, NN` line near the top. A ticket is unblocked when every file it lists has `Wayfinding: resolved`.
- **Frontier**: scan `.scratch/<effort>/issues/` for tickets with `Wayfinding: open` that are unblocked; the lowest numeric prefix wins.
- **Claim**: set `Wayfinding: claimed` and save before any work.
- **Resolve**: append the answer under an `## Answer` heading, set `Wayfinding: resolved`, then append an index line (name linked, one-line gist) to the map's Decisions so far in `map.md`.
