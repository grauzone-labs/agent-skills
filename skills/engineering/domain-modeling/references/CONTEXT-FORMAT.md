# CONTEXT.md format

## Select the context

When `docs/agents/domain.md` exists, load it first. It defines the repository-specific domain-document layout.

Otherwise use these defaults:

- If `CONTEXT-MAP.md` exists at the repository root, read it to find the context for the current topic.
- If only a root `CONTEXT.md` exists, use the single root context.
- If neither exists, create a root `CONTEXT.md` lazily when the first term is resolved.

For a multi-context repository, update the context selected by `CONTEXT-MAP.md`. If the topic crosses contexts, keep each term in its owning context and make the relationship explicit in the map or the relevant glossary entries. Ask the user when ownership remains unclear.

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
- **Keep definitions tight.** One or two sentences maximum. Define what the term is, not how it is implemented.
- **Keep the glossary context-specific.** Include concepts unique to the context; leave general programming concepts out.
- **Group related terms.** Use subheadings when natural clusters emerge; keep a flat list only when the terms form one cohesive area.

## Example context map

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
