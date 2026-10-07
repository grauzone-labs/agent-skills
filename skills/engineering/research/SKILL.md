---
name: research
description: Researches a bounded question and writes a cited finding from authoritative sources. Use when the user asks to research, look up, or verify a decision, documentation, API, or source-code fact of an examined system.
compatibility: Requires network access for online sources and a host with a subagent dispatch tool for the lead-and-worker split.
license: MIT
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "engineering"
---

# Research

A **finding** is one Markdown file that answers a bounded question with claim-level evidence. The source that owns a claim is **authoritative**: official vendor documentation, specifications, source code, and the API or reference material of the system being examined. Issue trackers, changelogs, forums, and vendor blogs corroborate at most; they never own a claim.

## Pick a role

- **Research lead** — any request not marked `Role: research worker`. Bounds the brief, dispatches one background research worker, verifies the finding, and owns every user-facing and tracker action. Dispatching the worker is this skill's split, not a re-delegation of your assignment. The lead performs the worker steps itself in place of its step 3 only when the host has no subagent dispatch tool or the dispatch call itself fails.
- **Research worker** — a dispatch marked `Role: research worker`. Investigates, writes the finding, and returns it to the lead.

## Research lead

1. **Bound the brief.** State the question, scope, source constraints, and repository root. For a `wayfinder` ticket, include the map and ticket links.

   **Complete when:** the worker can answer one checkable question without choosing its own scope.

2. **Choose the finding path.** Use the location the user or ticket names; otherwise the repository's existing research-note convention; otherwise `docs/research/<topic-slug>.md`, with a slug that collides with no existing note.

   **Complete when:** one exact, writable path is fixed.

3. **Dispatch the worker.** Send the brief, the path, `Role: research worker`, and the instruction to load the `research` skill. Dispatch with the host's background option where it has one (`run_in_background: true` on Claude Code).

   **Complete when:** one background worker owns the investigation and has the complete brief.

4. **Verify and deliver.** Read the finding at the path. Where the file is missing or a material claim in **Answer** lacks an **Evidence** entry, send the gap back to the worker and re-check on return. Then, in your response to the requester, state the path, the answer, and the caveats themselves; a pointer to the file's caveats does not count. For a `wayfinder` ticket, the session that claimed it posts the resolution comment, closes the ticket, and appends its index line to the map; a lead that did not claim it leaves those three to that session.

   **Complete when:** the finding passes the check and your response itself carries the path, the answer, and the caveats.

## Research worker

1. **Trace the evidence.** Answer the brief's question; follow every material factual claim of that answer through to the authoritative source that owns it; read enough surrounding context to preserve qualifications, versions, and limits.

   **Complete when:** every material conclusion is supported by an authoritative, directly linked source or is marked as an inference or unresolved question.

2. **Write the finding.** Create the file at the assigned path with these sections:

   ```markdown
   # <Question>

   ## Answer
   <Concise, evidence-backed answer.>

   ## Evidence
   - <Claim> — [Source title](URL or path from the repository root, such as `docs/CONTRIBUTING.md`) (<relevant version, section, or location>)

   ## Caveats and open questions
   <Uncertainty, source conflicts, assumptions, or an explicit “None found”.>
   ```

   **Complete when:** the file exists at the assigned path, every material claim in **Answer** has a corresponding entry in **Evidence**, and caveats distinguish source-backed facts from inference. If the file cannot be written, return the attempted path, the write error, and the draft finding to the lead.

3. **Return the result.** Return the exact path, the concise answer, the source links, and the caveats to the lead.

   **Complete when:** the lead holds the path, the answer, the sources, and the caveats.
