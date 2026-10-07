# Spec: rename `CustomerId` to `AccountId`

The shared `CustomerId` type is referenced in 41 files across the `billing`, `auth`, and `reporting` packages and in the public API types. Rename it to `AccountId` everywhere, keeping the public API backward compatible for one release.

## Decisions

- The published API keeps accepting `customerId` fields and emits `accountId` beside them until the next major release.
- CI must stay green on every commit; no package may be left in a half-renamed state.
