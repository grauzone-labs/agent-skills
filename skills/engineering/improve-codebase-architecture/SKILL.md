---
name: improve-codebase-architecture
description: Scans a codebase for deepening opportunities, compares them in a visual HTML report, then explores a chosen candidate with the user. Use when asked to review or improve architecture, module boundaries, or codebase navigability.
license: MIT
compatibility: Uses git history, a sub-agent tool, and a desktop opener (xdg-open, open, or start) when present, falling back to in-session inspection and path-only delivery; viewing the report needs network access to the Tailwind and Mermaid CDNs.
disable-model-invocation: true
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "engineering"
---

# Improve codebase architecture

Surface architectural friction and propose **deepening opportunities**: refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

Before the review, load the `codebase-design` skill. It is the single source of truth for **module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality**, the deletion test, and dependency categories.

## Process

### 1. Explore

1. Establish the repository root and the available evidence: version-control history, relevant code, callers, tests, and dependency declarations.
2. Establish the document layout through the `domain-modeling` skill's **Establish the document layout** step. Record an unavailable history, `CONTEXT.md`, or ADR directory as absent evidence rather than inferring its contents.
3. Determine scope:
   - When the user names a module, subsystem, or pain point, use that direction.
   - Otherwise, inspect the most recent 200 commits (the whole history when shorter) for paths that recur. Let a concentrated hot spot set the initial scope; when the changes are dispersed, compare the three most recurrent areas.
   - When the user gave no scope and history is absent or holds no source changes, report that gap and ask for a module, subsystem, or pain point; resume once the scope is named.
4. Read each selected `CONTEXT.md` and the ADRs affecting the scope before interpreting its seams. Spawn a sub-agent with the selected scope and evidence requirements. Have it inspect the involved modules, their callers, tests, and dependencies, then return observed friction with file-level evidence. Where the host has no sub-agent tool, does not let you spawn one, or the dispatch fails, say which in your response, then run that inspection yourself.
5. Assess observed friction through these lenses:
   - Understanding one concept requires moving across several modules.
   - A module is **shallow**.
   - Logic extracted for testability leaves its call-site behavior untested, reducing **locality**.
   - Coupled modules leak across a **seam**.
   - An interface makes behavior difficult to test.
6. Apply the **deletion test** to each plausible candidate. Classify its dependencies using the dependency categories in the `codebase-design` skill's `DEEPENING.md`, so its future test surface is credible.
7. Calibrate each candidate from the evidence:
   - **Strong** — repeatable friction in the selected scope, a deletion test that supports deepening, and a credible dependency/test shape.
   - **Worth exploring** — observed friction and a plausible deepening, with a material dependency or ownership question still open.
   - **Speculative** — a concrete hypothesis whose next observation can confirm or reject it.

**Complete when:** every reported candidate has file-level evidence, a stated source of friction, a deletion-test result, a category for each dependency, and a calibrated strength; unavailable repository or domain evidence is explicit.

### 2. Present candidates as an HTML report

Load [HTML-REPORT.md](references/HTML-REPORT.md) before composing the report. It is the single source of truth for the report scaffold, card structure, diagrams, and visual style.

Write one HTML file to the OS temp directory, keeping the repository unchanged. Resolve the temp directory from `$TMPDIR`, falling back to `/tmp` on Linux/macOS or `%TEMP%` on Windows. Write to `<tmpdir>/architecture-review-<timestamp>.html` so each run gets a fresh file. Re-read the written file against the candidate card fields and the top-recommendation anchor; fix omissions and broken anchors, then repeat until it passes. Open it with `xdg-open` on Linux, `open` on macOS, or `start` on Windows, and return its absolute path. When the open command fails or no opener exists, report that the file was not opened and return the path anyway. When the write is denied, state in your response that the report could not be written and why, then give every candidate with its strength and file-level evidence, and the top recommendation, in the reply itself.

Keep each candidate at decision level; reserve alternative interface design for step 3.

Surface an ADR conflict on a candidate's card only when observed friction warrants reconsidering that decision.

When one or more candidates are evidence-backed, end the reply, with or without a written report, by asking: **“Which of these would you like to explore?”** When none are evidence-backed, state that outcome, list the examined scope and unavailable evidence, and ask whether the user wants a broader or differently focused scan.

**Complete when:** the HTML file exists at a unique temporary path, contains every evidence-backed candidate and, when any exist, one evidence-backed top recommendation, and its absolute path has been returned together with the outcome of opening it; or, when the write was denied, the reply states that and carries the candidates and top recommendation.

### 3. Explore the selected candidate

Once the user chooses a candidate, run the `grilling` skill composed with the `domain-modeling` skill to work the candidate's **design tree** with them: constraints, dependencies, the deepened module's responsibility, its seam, what remains behind it, and the tests that survive. Two cases are specific to this review:

- A settled deepened-module name introduces a domain concept: capture the term in its owning glossary through the `domain-modeling` skill.
- The user rejects the candidate for a durable, non-obvious reason: offer to record that decision as an ADR so a future review does not reopen the proposal.

When the user asks to compare alternative interfaces, run **design it twice** from the `codebase-design` skill.

**Complete when:** the `grilling` skill's completion criterion holds for the selected candidate.
