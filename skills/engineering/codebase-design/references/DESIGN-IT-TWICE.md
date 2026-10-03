# Design it twice

When the user wants to explore alternative interfaces for a chosen deepening candidate, use this parallel sub-agent pattern. Based on "Design It Twice" (Ousterhout) — your first idea is unlikely to be the best.

Uses the vocabulary in [SKILL.md](../SKILL.md) — **module**, **interface**, **seam**, **adapter**, **leverage**.

## Process

### 1. Establish shared language and frame the problem space

Before spawning sub-agents, establish the domain-document layout through the `domain-modeling` skill when the candidate comes from a codebase. Collect the selected domain vocabulary and ADRs affecting the candidate; when they are unavailable, record that absence and use current code terminology as evidence.

Then write a user-facing explanation of the problem space for the chosen candidate:

- The constraints any new interface would need to satisfy
- The dependencies it would rely on, and which category they fall into (see `DEEPENING.md`)
- A rough illustrative code sketch to ground the constraints — not a proposal, just a way to make the constraints concrete

Show this to the user, then launch Step 2 while the user reads and thinks.

### 2. Spawn sub-agents

Spawn three sub-agents in parallel. Each must produce a **radically different** interface for the deepened module.

Prompt each sub-agent with a separate technical brief: file paths, coupling details, dependency category from `DEEPENING.md`, what sits behind the seam, and the selected domain vocabulary and applicable ADRs from Step 1. The brief is independent of the user-facing problem-space explanation. Give each agent a different design constraint:

- Agent 1: "Minimize the interface — aim for 1–3 entry points max. Maximise leverage per entry point."
- Agent 2: "Maximise flexibility — support many use cases and extension."
- Agent 3: "Optimise for the most common caller — make the default case trivial."
- For a cross-seam dependency, require the relevant brief to state whether a port earns an external seam under `DEEPENING.md`'s seam discipline.

Include the [SKILL.md](../SKILL.md) vocabulary in every brief so each sub-agent names architectural roles consistently.

Each sub-agent outputs:

1. Interface (types, methods, params — plus invariants, ordering, error modes)
2. Usage example showing how callers use it
3. What the implementation hides behind the seam
4. Dependency strategy and adapters (see `DEEPENING.md`)
5. Trade-offs — where leverage is high, where it's thin

### 3. Present and compare

Present designs sequentially so the user can absorb each one, then compare them in prose. Contrast by **depth** (leverage at the interface), **locality** (where change concentrates), and **seam placement**.

After comparing, give your own recommendation: which design you think is strongest and why. If elements from different designs would combine well, propose a hybrid. Be opinionated — the user wants a strong read, not a menu.

**Complete when:** three distinct interface designs have stated their interfaces, usage, hidden implementation, dependency strategies, and trade-offs; the comparison covers **depth**, **locality**, and **seam placement**; and the recommendation identifies a strongest design or a justified hybrid.
