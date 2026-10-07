# Deepening

How to assess a cluster of shallow modules for safe deepening, given its dependencies.

Deepen only when observed friction, a coherent responsibility, and the **deletion test** show that complexity can become more local. The dependency category sets a credible test strategy for that candidate; it does not independently justify a merge or a new seam.

## Dependency categories

Classify the candidate's dependencies; the category determines how the deepened module is tested across its seam.

### 1. In-process

Pure computation, in-memory state, no I/O. When the candidate earns deepening, merge the collaborating behaviour and test through the new interface directly. No adapter is needed.

### 2. Local-substitutable

Dependencies that have local test stand-ins (PGLite for Postgres, in-memory filesystem). When the candidate earns deepening and the stand-in covers the required behaviour, test the deepened module with the stand-in running in the test suite. Keep this seam internal by default; expose it only when the external-seam principle in codebase-design justifies it. If the stand-in cannot reproduce required behaviour, use the real dependency in an integration test and state the uncovered behaviour.

### 3. Remote but owned (Ports & Adapters)

Your own services across the network (microservices, internal APIs). When transport or ownership genuinely varies at that seam, define a **port** — the interface at an external seam. The deep module owns the logic; the transport is injected as an **adapter**. Tests can use an in-memory adapter; production can use an HTTP/gRPC/queue adapter.

### 4. True external

Third-party services (Stripe, Twilio, etc.) you don't control. Where the module needs to isolate the provider-specific contract, take the external dependency as an injected port and provide a test adapter that models the required outcomes.

## Testing strategy: centre tests on the interface

- Write new caller-facing tests at the deepened module's interface, asserting observable outcomes rather than internal state, so they describe behaviour and survive internal refactors.
- Retain internal tests that independently protect algorithmic edge cases, dependency interactions, or failure modes. Remove a pre-existing test only when the new interface-level coverage demonstrably makes it redundant.

## Assessment output

```md
- Candidate and responsibility: <scope>
- Friction and deletion test: <evidence; where complexity moves>
- Recommendation: <deepen, retain, or defer pending named evidence>
- Proposed interface: <entry points and caller obligations>
- Dependencies: <each dependency: category, internal or external seam and why, test strategy>
- Coverage: <observable outcomes tested at the interface; internal tests retained or demonstrably redundant>
```

**Complete when:** every dependency has a category, a justified seam placement, and a test strategy, and the recommendation follows from the friction, responsibility, and deletion-test evidence.
