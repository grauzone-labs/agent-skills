# Spec: saved searches

Users can save the current search filters under a name and rerun them later.

## Decisions

- A saved search belongs to the user who created it and is private.
- Saving requires a name unique per user; a duplicate name is rejected with a validation error.
- The search page lists the user's saved searches; selecting one applies its filters.
- Deleting a saved search removes it from the list immediately.

## Testing decisions

- Saving, listing, applying, and deleting are proven at the HTTP API seam.
- Uniqueness is proven at the repository seam.
