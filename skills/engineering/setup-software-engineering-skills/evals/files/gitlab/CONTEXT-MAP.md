# Context map

## Contexts

- **Ordering** - `packages/ordering/CONTEXT.md`: order intake, pricing, and fulfilment hand-off
- **Billing** - `packages/billing/CONTEXT.md`: invoicing and payment collection

## Relationships

- Ordering publishes `OrderPlaced`; Billing consumes it to open an invoice.
