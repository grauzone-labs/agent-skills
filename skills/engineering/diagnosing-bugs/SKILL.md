---
name: diagnosing-bugs
description: Runs a diagnosis loop for hard bugs and performance regressions, building a tight feedback loop that goes red on the bug before any hypothesis. Use when the user says "diagnose" or "debug this", or reports something broken, throwing, failing, or slow.
compatibility: Requires bash for the HITL script and git for bisection. HTTP, headless-browser, and test loops use whatever the project already provides.
license: MIT
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "engineering"
---

# Diagnosing bugs

Skip a phase only when you state why. When exploring the codebase, use the project's domain vocabulary: read `docs/agents/domain.md` when it exists, then the relevant `CONTEXT.md` and the ADRs in the area you are touching.

## Progress

Record the six phases below in the host's task list tool, one task per phase, before Phase 1, and mark each done as its completion criterion holds. Where the host offers no task list tool, copy this checklist into your first response and tick it there instead. The task list tracks progress only; the evidence each phase names goes in your response to the user.

- [ ] 1. [Build a feedback loop](#phase-1-build-a-feedback-loop)
- [ ] 2. [Reproduce and minimise](#phase-2-reproduce-and-minimise)
- [ ] 3. [Hypothesise](#phase-3-hypothesise)
- [ ] 4. [Instrument](#phase-4-instrument)
- [ ] 5. [Fix and regression test](#phase-5-fix-and-regression-test)
- [ ] 6. [Cleanup](#phase-6-cleanup)

## Redact

**Redact every secret** in every command, output, and captured artifact you show: write `<REDACTED>` in its place. Build loops against env vars, so the credential stays in the environment rather than in what you show. Captured artifacts carry auth headers: quote only the lines that carry the signal.

If the redacted output is not enough to diagnose the bug, stop with the blocked report below.

## Phase 1: build a feedback loop

**Be relentless** about building a **tight** loop that goes **red** on this bug.

### Ways to construct one, in roughly this order

For performance regressions, measure the baseline timing before changing anything; the loop asserts the symptom against that threshold.

1. **Failing test** at whatever seam reaches the bug: unit, integration, e2e.
2. **Curl / HTTP script** against a running dev server.
3. **CLI invocation** with a fixture input, diffing stdout against a known-good snapshot.
4. **Headless browser script** (Playwright / Puppeteer) that drives the UI and asserts on DOM/console/network.
5. **Replay a captured trace.** Save a real network request / payload / event log to disk; replay it through the code path in isolation.
6. **Throwaway harness.** Spin up a minimal subset of the system (one service, mocked deps) that exercises the bug code path with a single function call.
7. **Property / fuzz loop.** If the bug is "sometimes wrong output", run 1000 random inputs and look for the failure mode.
8. **Bisection harness.** If the bug appeared between two known states (commit, dataset, version), automate "boot at state X, check, repeat" so you can `git bisect run` it.
9. **Differential loop.** Run the same input through old-version vs new-version (or two configs) and diff outputs.
10. **HITL bash script.** Last resort. If a human must click, drive _them_: copy [`scripts/hitl-loop.template.sh`](scripts/hitl-loop.template.sh), edit the scenario between its markers, and have the user run the copy in their terminal and paste its output back: the captured values and a `RED`, `GREEN`, or `INCOMPLETE` verdict line.

### Tighten the loop

Once you have _a_ loop, **tighten** it:

- Can I make it faster? (Cache setup, skip unrelated init, narrow the test scope.)
- Can I make the signal sharper? (Assert on the specific symptom, not "didn't crash".)
- Can I make it more deterministic? (Pin time, seed RNG, isolate filesystem, freeze network.)

### Non-deterministic bugs

Make the command a fixed batch of trials (start at 100): red when any trial shows the exact symptom, green when none does. Parallelise, add stress, narrow timing windows, inject sleeps until two consecutive batches go red; after the fix, demand two consecutive green batches.

### When you genuinely cannot build a loop

Stop and report in this form, asking for the smallest input that would unblock you:

```text
Blocked phase: <phase>
Tried: <each construction or probe — its result or the access constraint>
Needed: <access to an environment that reproduces it | a redacted captured artifact (HAR file, log dump, core dump, screen recording with timestamps) | permission to add temporary production instrumentation>
```

### Completion criterion: a tight loop that goes red

Phase 1 is done when the loop is **tight** and **red-capable**: you can name **one command** (a script path, a test invocation, a curl) that has **already gone red on the reported symptom** (show the invocation and its red output, redacted, in your response to the user; for HITL, the output the user pasted back), and that is:

- [ ] **Red-capable**: it drives the actual bug code path and asserts the **user's exact symptom**, so it can go red on this bug and green once fixed.
- [ ] **Deterministic**: same verdict every run (flaky bugs: the batch criterion above).
- [ ] **Fast**: seconds, not minutes.
- [ ] **Agent-runnable**: you can run it unattended; a human in the loop only via the HITL script.

Until this command exists, read code only to find the trigger and build the loop; theories wait for Phase 3. No red-capable command, no Phase 2.

## Phase 2: reproduce and minimise

Confirm the red run shows the failure mode the **user** described rather than a nearby one, and record the exact symptom (error message, wrong output, slow timing) for Phase 6 to verify the fix against.

### Minimise

Once it's red, shrink the repro to the **smallest scenario that still goes red**. Cut inputs, callers, config, data, and steps **one at a time**, re-running the loop after each cut, and keep only what's load-bearing for the failure.

Phase 2 is done when **every remaining element is load-bearing** (removing any one of them makes the loop go green or stops it reaching the bug path) and your response to the user lists each cut with its loop verdict and shows the minimised repro still red.

## Phase 3: hypothesise

Generate **3–5 ranked hypotheses** before testing any of them. Each must be **falsifiable**: state the prediction it makes.

> Format: "If <X> is the cause, then <changing Y> will make the bug disappear / <changing Z> will make it worse."

Phase 3 is a hard gate: write the ranked list, one prediction per hypothesis, as text in your response to the user before your first Phase 4 probe; a list kept only in a tool call or a file does not count. Proceed with your ranking; re-rank when the user answers, using any new evidence they supply.

## Phase 4: instrument

Each probe must map to a specific prediction from Phase 3. **Change one variable at a time.**

Tool preference:

1. **Debugger / REPL inspection** if the env supports it.
2. **Targeted logs** at the boundaries that distinguish hypotheses.

**Tag every debug log** with a unique prefix, e.g. `[DEBUG-a4f2]`, so cleanup is a single grep.

**Perf branch.** For performance regressions, probes are measurements (timing harness, `performance.now()`, profiler, query plan) against the Phase 1 baseline; when a good and a bad state are known, bisect with the timing loop.

Phase 4 is done when exactly one hypothesis survives: its prediction held in the loop and the probes falsified the others. When several survive, probe to separate them or merge them into one hypothesis of interacting causes. When none survives, return to Phase 3 with what the probes showed. When access or missing evidence prevents a probe, stop with the blocked report.

## Phase 5: fix and regression test

Write the regression test **before the fix**, but only if there is a **correct seam** for it. The `codebase-design` skill owns the seam vocabulary.

A correct seam is one where the test exercises the **real bug pattern** as it occurs at the call site. Choose a test scope that includes the triggering call sequence (multiple callers when required); a narrower test does not lock down that pattern.

**If no correct seam exists, that itself is the finding.** Note it for Phase 6: the codebase architecture is preventing the bug from being locked down.

If a correct seam exists:

1. Turn the minimised repro into a failing test at that seam.
2. Watch it fail.
3. Apply the fix.
4. Watch it pass.

Phase 5 is done when the regression test passes, or the missing seam is noted and the fix is applied.

## Phase 6: cleanup

Before declaring done, make every line of this report true, then send it with each item on its own ticked line:

```text
- [x] Original repro no longer reproduces: <Phase 1 loop re-run against the original, un-minimised scenario, and its green output>
- [x] Regression test passes: <command and result> | Missing seam documented: <where>
- [x] Debug instrumentation removed: <grep for the [DEBUG-...] prefix, no matches>
- [x] Throwaway harnesses deleted | moved to <clearly-marked debug location>
- [x] Confirmed cause: <hypothesis and the probe result that confirmed it>, also stated in the commit / PR message when one is written
```
