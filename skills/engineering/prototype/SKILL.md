---
name: prototype
description: Builds a throwaway prototype to answer a design question. Use when the user wants to sanity-check whether a state model or logic feels right, or explore what a UI should look like.
license: MIT
compatibility: Requires git for the throwaway branch. Verification drives the prototype in a browser or preview tool the agent can operate; without one, the checks pass to the reviewer.
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "engineering"
---

# Prototype

A prototype is **throwaway code that answers a question**. The question decides the shape.

## Pick a branch

Identify which question is being answered — from the user's prompt, the surrounding code, or by asking if the user is around:

- **"Does this logic / state model feel right?"** → [LOGIC.md](references/LOGIC.md): a single HTML file with free-play buttons and guided walkthroughs that a non-developer can drive.
- **"What should this look like?"** → [UI.md](references/UI.md): several radically different variants of one route, switchable through a URL search param and a floating bottom bar.

If the question is genuinely ambiguous and the user is not reachable, take the branch that matches the surrounding code (a backend module → logic; a page or component → UI) and open the prototype's visible top paragraph with the branch taken and why, for example "Logic branch: `billing/invoice.ts` is a backend module with no page or component."

## Rules that apply to both

1. **Mark it as throwaway.** Locate prototype code close to where it will be used and name it so a casual reader identifies it as a prototype.
2. **Make it trivial to run.** A UI prototype starts from one command in the project's task runner. A logic demo is a single HTML file the user opens directly.
3. **Keep state local by default.** Use in-memory state. When persistence is the question, use a clearly named scratch database or local file that is safe to wipe.
4. **Keep the scope tight.** Write only the code needed to answer the question and make it runnable.
5. **Capture it after the verdict.** Only after the reviewer has given the verdict, carry the validated decision — a reducer, state machine, schema, or type shape — into the real code under the target module's normal production standards; main retains only that decision. Preserve the executable prototype as the **primary source** on a throwaway branch outside main. Record the question, verdict, and branch reference on the implementation issue; without an issue, on the repository's normal planning artifact or the decision commit. Mark decision-rich excerpts in the specification or ticket as prototype-derived, linked to the executable prototype as their primary source. Complete when the branch reference resolves to the runnable prototype and the recorded verdict matches the production change.

## Hand-off

In your response to the reviewer, reproduce these four labelled lines verbatim and complete, each on its own line under its own label, none merged, renamed, or recast as prose; the verdict stays with the reviewer:

```text
Question: <design question>
Prototype: <HTML path, or route URL and variant keys>
Run: <open the file, or the task-runner command>
Checks: <every check passed, or the checks listed for the reviewer when no browser is available>
```
