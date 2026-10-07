---
name: wayfinder
description: Plans an initiative too large for one agent session as a shared map of decision tickets on the issue tracker, and resolves them one session at a time until the way to the destination is clear. Use when the user asks to chart a map for a loose idea, or names an existing Wayfinder map or one of its tickets to work.
compatibility: Requires the tracker contract in docs/agents/issue-tracker.md written by setup-software-engineering-skills, that tracker's CLI or file tools, and the grilling, domain-modeling, research, and prototype skills of this collection. Research tickets need a host with a subagent dispatch tool.
license: MIT
disable-model-invocation: true
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "engineering"
---

# Wayfinder

## Table of contents

- [Plan the route](#plan-the-route)
- [Refer by name](#refer-by-name)
- [The map](#the-map)
  - [The map body](#the-map-body)
  - [Tickets](#tickets)
- [Ticket types](#ticket-types)
- [Fog of war](#fog-of-war)
- [Out of scope](#out-of-scope)
- [Invocation](#invocation)
  - [Chart the map](#chart-the-map)
  - [Work through the map](#work-through-the-map)

A loose idea has arrived - too big for one agent session, and wrapped in fog: the way from here to the **destination** isn't visible yet. This skill charts the way as a **shared map** on the repo's issue tracker, then works its **decision tickets** - questions whose resolution is a decision, not slices of a build - until the way is clear.

The destination varies per effort, and naming it is the first act of charting: a spec to hand off, a decision to lock before planning starts, or a change made in place such as a data-structure migration.

## Plan the route

Wayfinder is **planning**: each ticket resolves a decision, and the map is done when nothing is left to decide before someone goes and does the thing. The pull to just do the work signals you've reached the edge of the map and it's time to hand off. An effort can override this in its **Notes** - carrying execution into the map itself - but absent that, record decisions and hand execution off.

## Refer by name

Every map and ticket is an issue, so it has a **name** - its title. In everything the human reads - narration, the map's Decisions so far - refer to it by that name, with its id, URL, or path riding inside the name's link.

## The map

The map is a single issue on this repo's issue tracker, labelled `wayfinder:map`. Its tickets are child issues of the map.

The map is an **index**, not a store. A decision lives in exactly one place - its ticket - so **Decisions so far** holds one **index line** per ticket closed by resolution: the ticket's name linked, then a one-line gist of the answer.

### The map body

The whole map at low resolution. Only closed tickets appear in it; open tickets are child issues found by query.

```markdown
## Destination

<what reaching the end of this map looks like - the spec, decision, or change this effort is finding its way to. One or two lines; every session orients to it before choosing a ticket.>

## Notes

<domain; skills every session should consult; standing preferences for this effort>

## Decisions so far

<!-- the index - one line per closed ticket: enough to judge relevance, then zoom the link for the detail the ticket holds -->

- [<closed ticket title>](link) - <one-line gist of the answer>

## Not yet specified

<!-- see "Fog of war": in-scope fog you can't ticket yet; graduates as the frontier advances -->

## Out of scope

<!-- see "Out of scope": work ruled beyond the destination; closed, never graduates -->
```

### Tickets

Each ticket is a **child issue** of the map; where the tracker lacks a native child relationship, the tracker contract defines the equivalent membership marker and query. The tracker's issue id is its identity. Put every membership and **Wayfinding order** field the contract requires at the top of the body, in its exact syntax and placement, assigning the order in breadth-first discovery order. The remaining body is the question, sized to one agent session:

```markdown
## Question

<the decision or investigation this ticket resolves>
```

Each ticket carries a `wayfinder:<type>` label - one of `research`, `prototype`, `grilling`, `task` (see [Ticket types](#ticket-types)).

A session **claims** a ticket with the tracker contract's claim operation, **first**, before any work, so concurrent sessions skip it. That claim marker _is_ the claim: an open ticket without it is unclaimed.

Blocking uses the dependency relationship the tracker contract defines - native where the tracker has one, so the frontier renders in the tracker's own UI. A ticket is **unblocked** when every ticket blocking it is closed; the **frontier** is the open, unblocked, unclaimed children - the edge of the known.

The answer is recorded on resolution as a **resolution comment** on the ticket (see [Work through the map](#work-through-the-map)), in this form:

```markdown
<the answer: the decision, the cited finding, or what the task did and the facts it produced>

Evidence: <links to the finding, prototype, ADR, or other assets created while resolving; or none>
Remaining questions: <what the answer surfaced, to ticket or add to fog; or none>
```

## Ticket types

Every ticket is either **HITL** - human in the loop, worked _with_ a human who speaks for themselves - or **AFK**, driven by the agent alone. A HITL ticket resolves only through that live exchange: the human's side of it comes from the human.

- **Research** (AFK): Source-backed investigation that surfaces a fact a decision waits on. Use when evidence outside the current session is required. After claiming, run the `research` skill as **research lead** with the map and ticket references; it dispatches and verifies one worker's cited finding. Complete when the verified finding answers the ticket's question; insufficient evidence leaves the ticket open with the gap reported. Record it per [Work through the map](#work-through-the-map) steps 4-5.
- **Prototype** (HITL): Raise the fidelity of the discussion by making a cheap, rough, concrete artifact to react to - an outline, a rough take, a stub, or UI/logic code via the `prototype` skill. Use when "how should it look" or "how should it behave" is the key question. Complete when the human, having reacted to the artifact, confirms the answer.
- **Grilling** (HITL): Conversation. The default case. Invoke the `grilling` and `domain-modeling` skills, bounded to this ticket's question. Complete when the human confirms its settled answer; decisions discovered on the way become tickets or fog.
- **Task** (HITL or AFK): Manual work that must happen before a _decision_ can be made - nothing to decide, prototype, or research, but the discussion is blocked until it's done. Signing up for a service so its API can be judged, provisioning access, moving data so its shape can be seen. This is the one type that _does_ rather than decides - and it earns its place by unblocking a decision, not by delivering the destination. The agent drives it alone where it can (AFK); otherwise it hands the human a checklist of `- [ ] <action> - done when <observable result>` lines (HITL). Resolved when every result is observed or confirmed by the human; the answer records what was done and any resulting facts (credentials location, new URLs, row counts) later tickets depend on.

## Fog of war

The map is _deliberately_ incomplete: chart only what you can see. Beyond the live tickets lies the **fog of war** - the dim view of decisions and investigations you can tell are coming but can't yet pin down, because they hang on questions still open. Resolving a ticket clears the fog ahead of it, graduating whatever's now specifiable into fresh tickets, until the way to the destination is clear and no tickets remain.

The map's **Not yet specified** section is where that dim view is written down: the suspected question, the area to revisit later. Everything here is in scope, just not sharp enough to ticket. Write as loosely or as fully as the view allows.

**Fog or ticket?** The test is whether you can state the question precisely now - _not_ whether you can answer it now.

- **Ticket when** the question is already sharp - even if it's blocked and you can't act on it yet.
- **Not yet specified when** you can't yet phrase it that sharply. Keep fog coarser than a ticket: one patch may graduate into several tickets, or none, once the frontier reaches it.

**Not yet specified** excludes what's already decided (Decisions so far), what's already a live ticket, and what's out of scope.

## Out of scope

The destination fixes the scope, so work beyond it is **out of scope** - not fog. It gets its own **Out of scope** section on the map: work you've consciously ruled out of _this_ effort. Scope, not sharpness, lands it here. Out-of-scope work never graduates - the frontier stops at the destination - so it returns only if the destination is redrawn, and then as a fresh effort.

When an existing ticket turns out to sit past the destination - mis-scoped in while charting, or exposed by a resolution - **close it** and leave one line in **Out of scope**: the gist plus why it's out, linking the closed ticket. It stays out of **Decisions so far**, which records only the route walked.

## Invocation

Before either mode, load `docs/agents/issue-tracker.md` and consult its **Wayfinding operations**: where the map, its child tickets, membership, blocking, claiming, and frontier order live is tracker-specific. If that document does not exist, stop and report that the `setup-software-engineering-skills` skill writes the tracker contract this skill consumes.

Each session resolves **exactly one** non-research ticket; research tickets are exempt because a subagent does their work.

Every stop ends with this report:

```text
Map: [<title>](<reference>), or not created
Completed: <linked tickets with one-line answers, or none>
Pending: <linked blocked or claimed tickets, remaining fog, or none>
Next: <next frontier ticket, required user action or missing prerequisite, or handoff>
```

### Chart the map

User invokes with a loose idea.

1. **Name the destination.** Run `grilling` and `domain-modeling`, with the design tree bounded to choosing the destination, to pin down what this map is finding its way to: your first message asks the user the destination question and ends the turn, even when the session looks unattended; reading the code answers none of it. Done when the destination fits in one or two lines the user has confirmed.
2. **Map the frontier.** Grill again, **breadth-first** this time: fan out across the whole space rather than deep on any one thread, surfacing the open decisions and the first steps takeable now - leaving their answers to their tickets. Done when each area the user names is a sharp question, a patch of fog, or an out-of-scope entry, and the user confirms coverage. **If no fog surfaces** - the whole journey fits one session - report that the way is already clear, ask the user how they'd like to proceed, and stop.
3. **Create the map** (label `wayfinder:map`): Destination and Notes filled in, Decisions so far empty, the fog sketched into **Not yet specified**.
4. **Create the tickets you can specify now** as child issues per [Tickets](#tickets), every one without blocking fields; only after all exist, add the blocking relationships in a **second pass**, even when the tracker's ids are known in advance.
5. **Resolve frontier research.** Resolve each frontier `research` ticket per [Ticket types](#ticket-types), re-querying the frontier after each, until no frontier research remains.
6. **Report and stop**: charting is one session's work.

**Complete when:** the map records its destination, notes, current fog, and an index line for each resolved research ticket; every currently specifiable ticket has its configured membership, order, type, and blocking relationship; frontier research is resolved or reported pending with its evidence gap; and no non-research ticket has been resolved.

### Work through the map

User invokes with a map (URL, number, or path) and optionally a ticket; without one, you pick the next decision.

1. **Load the map** - the map body only; the frontier query reads ticket metadata, and ticket bodies are fetched on demand in step 3.
2. **Choose the ticket.** If the user named one, use it; if it is not a child of this map, or is closed, claimed, or blocked, report that state and stop. Otherwise take the first frontier ticket in the tracker's order; if the frontier is empty, report whether open tickets remain (blocked or claimed) or the map is complete, and stop. **Claim it** per [Tickets](#tickets) before any work.
3. **Resolve it** per its [type](#ticket-types), invoking the skills the map's **Notes** name. **Zoom as needed**: fetch the full body of any related or closed ticket on demand. Proceed when the type's completion criterion holds; otherwise report the gap and stop with the ticket open.
4. **Record the resolution**: post the answer as a **resolution comment**, **close** the ticket, and **append its index line** to Decisions so far.
5. **Update the map**: create newly surfaced tickets (create, then wire); graduate fog the answer has made specifiable, removing each graduated patch from **Not yet specified** so it lives only as its ticket; rule out of scope any ticket the answer shows sits past the destination; update the tickets the decision invalidates, or close them with the reason and re-wire their dependents.
6. **Continue or stop.** After a `research` ticket, return to step 2; after any other ticket, report and stop.

**Complete when:** exactly one non-research ticket, and each research ticket resolved before it, has a resolution comment, the tracker state the contract requires, and its index line; every newly specifiable decision has a correctly wired ticket or remains in fog; and the map's out-of-scope and invalidated work reflects the resolution.
