# Deepening

How to assess a cluster of shallow modules for safe deepening, given its dependencies. Assumes the vocabulary in [SKILL.md](../SKILL.md) — **module**, **interface**, **seam**, **adapter**.

Deepen only when observed friction, a coherent responsibility, and the **deletion test** show that complexity can become more local. The dependency category sets a credible test strategy for that candidate; it does not independently justify a merge or a new seam.

## Dependency categories

When assessing a candidate for deepening, classify its dependencies. The category determines how the deepened module is tested across its seam.

### 1. In-process

Pure computation, in-memory state, no I/O. When the candidate earns deepening, merge the collaborating behaviour and test through the new interface directly. No adapter is needed.

### 2. Local-substitutable

Dependencies that have local test stand-ins (PGLite for Postgres, in-memory filesystem). When the candidate earns deepening and the stand-in covers the required behaviour, test the deepened module with the stand-in running in the test suite. The seam can remain internal rather than becoming a port at the module's external interface.

### 3. Remote but owned (Ports & Adapters)

Your own services across a network boundary (microservices, internal APIs). When transport or ownership genuinely varies at that seam, define a **port** (interface). The deep module owns the logic; the transport is injected as an **adapter**. Tests can use an in-memory adapter; production can use an HTTP/gRPC/queue adapter.

Recommendation shape: *"This transport and ownership variation earns an external port at the seam. Implement an HTTP adapter for production and an in-memory adapter for testing, so the logic sits in one deep module even though it's deployed across a network."*

### 4. True external

Third-party services (Stripe, Twilio, etc.) you don't control. Where the module needs to isolate the provider-specific contract, take the external dependency as an injected port and provide a test adapter that models the required outcomes.

## Seam discipline

- **Earn external seams through variation.** Give a port an external interface when production behaviour, ownership, or deployment varies across it. A test adapter validates that justified seam; it does not alone establish one. Keep test-only seams internal.
- **Internal seams vs external seams.** A deep module can have internal seams (private to its implementation, used by its own tests) as well as the external seam at its interface. Don't expose internal seams through the interface just because tests use them.

## Testing strategy: centre tests on the interface

- Write new caller-facing tests at the deepened module's interface. The external **interface is the caller test surface**.
- Caller-facing tests assert on observable outcomes through that interface, not internal state.
- Design caller-facing tests to survive internal refactors: they describe behaviour, not implementation.
- Retain internal tests that independently protect algorithmic edge cases, dependency interactions, or failure modes. Remove a pre-existing test only when the new interface-level coverage demonstrably makes it redundant.
