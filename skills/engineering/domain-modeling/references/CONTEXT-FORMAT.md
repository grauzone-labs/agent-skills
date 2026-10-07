# CONTEXT.md format

The default format for the glossary in a `CONTEXT.md` and for the `CONTEXT-MAP.md` of a multi-context repository.

## Structure

```md
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**Order**:
{A one or two sentence description of the term}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others under `_Avoid_`.
- **Keep definitions tight.** One or two sentences maximum. Define the term's domain meaning.
- **Keep the glossary context-specific.** Include domain concepts with a meaning specific to this context.
- **Group related terms.** Use subheadings when natural clusters emerge; keep a flat list only when the terms form one cohesive area.

## Context map

A multi-context repository keeps one `CONTEXT-MAP.md` at the repository root. When a topic crosses contexts, keep each term in its owning context's `CONTEXT.md` and record the relationship under `## Relationships` in the map.

```md
# Context map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) - receives and tracks customer orders
- [Billing](./src/billing/CONTEXT.md) - generates invoices and processes payments
- [Fulfillment](./src/fulfillment/CONTEXT.md) - manages warehouse picking and shipping

## Relationships

- **Ordering -> Fulfillment**: Ordering emits `OrderPlaced` events; Fulfillment consumes them to start picking.
- **Fulfillment -> Billing**: Fulfillment emits `ShipmentDispatched` events; Billing consumes them to generate invoices.
- **Ordering <-> Billing**: Shared types for `CustomerId` and `Money`.
```
