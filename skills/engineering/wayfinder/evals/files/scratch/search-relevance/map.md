# Search relevance overhaul

## Destination

A written spec for replacing the product catalogue's keyword search with ranked relevance, ready to hand to the implementing team.

## Notes

Domain: e-commerce catalogue with 40k products. Consult the `domain-modeling` skill in every session. The team prefers managed services over self-hosting.

## Decisions so far

- [Which queries fail today](issues/01-failing-queries.md) - synonyms and misspellings account for most zero-result searches; the top 50 are listed in the ticket.

## Not yet specified

- Measuring relevance once a ranking exists; what can be measured depends on the signals the chosen engine exposes.
- Personalisation: whether and how far it belongs in this effort, to revisit once the engine's capabilities are known.

## Out of scope
