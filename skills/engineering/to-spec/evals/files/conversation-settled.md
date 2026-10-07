# Conversation so far

User: Customers keep asking support for a CSV of their orders. Let's add an export.

Agent: Where should it live? The orders page already has a filter bar and a "Print" action in `OrdersToolbar`.

User: Next to Print: an "Export CSV" button. It exports exactly the orders matching the current filters, as a file download, with the columns order number, placed date, status, and total in the store currency.

Agent: Order lists are served by `GET /api/orders`, which takes the same filter parameters as the page. Reusing it with an `Accept: text/csv` header keeps one filter implementation. Rows beyond the page size would need the handler to stream all matches.

User: Yes, reuse that route with the Accept header, and stream every match, not just the current page. Only users with the `orders:read` permission can export; everyone else gets the usual 403. Empty result: a CSV with the header row only.

Agent: The existing `orders.api.test.ts` covers `GET /api/orders` through the HTTP layer with a seeded store, so the export can be proved there.

User: Good. Ship it as an enhancement; it is not fixing anything broken.
