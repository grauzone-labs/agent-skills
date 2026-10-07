---
name: codebase-design
description: Shared vocabulary for designing deep modules. Use when the user wants to design or improve a module's interface, find deepening opportunities, decide where a seam goes, make code more testable, or when another skill needs the deep-module vocabulary.
license: MIT
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "engineering"
---

# Codebase design

Design **deep modules**: a lot of behaviour behind a small interface, placed at a clean seam, testable through that interface. Use this language and these principles wherever code is being designed or restructured.

## Glossary

Use this vocabulary for architectural roles and outcomes. Preserve repository domain names, file names, protocol names, and quoted code terminology as evidence.

**Module** — anything with an interface and an implementation. Deliberately scale-agnostic: a function, class, package, or tier-spanning slice.

**Interface** — the one external surface a module presents to callers and black-box tests: everything a caller must know to use the module correctly — the type signature, but also invariants, ordering constraints, error modes, required configuration, and performance characteristics.

**Implementation** — what's inside a module, its body of code.

**Depth** — leverage at the interface: the amount of behaviour a caller (or test) can exercise per unit of interface they have to learn. A module is **deep** when a large amount of behaviour sits behind a small interface, **shallow** when the interface is nearly as complex as the implementation.

**Seam** _(Michael Feathers)_ — a place where you can alter behaviour without editing in that place; the *location* at which a module's interface lives. Where to put the seam is its own design decision, distinct from what goes behind it.

**Adapter** — a concrete thing that satisfies an interface at a seam. Describes *role* (what slot it fills), not substance (what's inside): a small adapter can have a large implementation (a Postgres repo), a large adapter a small one (an in-memory fake). Say "adapter" when the seam is the topic, "implementation" otherwise.

**Leverage** — what callers get from depth: one implementation pays back across N call sites and M tests.

**Locality** — what maintainers get from depth: change, bugs, knowledge, and verification concentrate in one place rather than spreading across callers. Fix once, fixed everywhere.

## Principles

- **Depth is a property of the interface, not the implementation.** A deep module can be internally composed of small, mockable, swappable parts — they just aren't part of the interface. A module can have **internal seams** (private to its implementation, used by its own tests) as well as the **external seam** at its interface.
- **Shrink the interface.** When designing one, ask: can I reduce the number of entry points, simplify the parameters, hide more complexity inside?
- **The deletion test.** Imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the caller test surface.** Callers and black-box tests cross the external seam. The module's own tests may exercise internal seams when they protect behaviour that the external interface does not cover directly.
- **Earn an external seam through variation.** Introduce an external seam when production behaviour, ownership, or deployment genuinely varies across it. A test adapter verifies that justified seam; it does not alone justify one. Keep test-only seams internal.

## Designing for testability

1. **Accept effectful dependencies at the seam that owns them.** Injection may sit at an internal seam; expose it on the interface only when the external-seam principle earns it.

   ```typescript
   // Testable
   function processOrder(order, paymentGateway) {}

   // Hard to test
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

2. **Make effects observable at the interface.** Return useful outcomes from a workflow, and route durable writes or external calls through accepted dependencies.

   ```typescript
   // A test can observe the outcome and control the payment adapter.
   function processOrder(order, paymentGateway): Receipt {
     const payment = paymentGateway.charge(order.total);
     return createReceipt(order, payment);
   }
   ```

## Rejected framings

- **Depth as ratio of implementation-lines to interface-lines** (Ousterhout): rewards padding the implementation. We use depth-as-leverage instead.
- **"Interface" as the TypeScript `interface` keyword or a class's public methods**: too narrow — interface here includes every fact a caller must know.
- **"Boundary"**: overloaded with DDD's bounded context. Say **seam** or **interface**.

## Going deeper

- **Assessing a deepening candidate** — open [DEEPENING.md](references/DEEPENING.md) for the dependency categories and the interface-centred test strategy.
- **Exploring alternative interfaces** — open [DESIGN-IT-TWICE.md](references/DESIGN-IT-TWICE.md) to design the interface several radically different ways in parallel sub-agents, then compare on depth, locality, and seam placement. Load `DEEPENING.md` alongside it: the sub-agent briefs cite its dependency categories.
