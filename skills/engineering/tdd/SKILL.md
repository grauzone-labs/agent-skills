---
name: tdd
description: Builds behavior test-first in a red, green, refactor loop at agreed public seams, one tracer bullet at a time. Use when implementing behavior that needs tests, when the user asks for test-first work, or when another skill builds a testable slice; `codebase-design` owns the shape of the seam itself.
compatibility: Requires a project test runner and the codebase-design skill of this collection.
license: MIT
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "engineering"
---

# Test-driven development

## Seams

A **seam** is where a module's public interface lives: the place a behavior is observed without reaching inside. Before the first test, write one line per behavior in your response to the user, in exactly this form: `Behavior: <capability>; Seam: <interface>; Agreement: <source or pending>`. A seam you chose yourself is pending: propose it on its line, end your turn by asking the user to agree, and write no test until the user's reply agrees. Done when every line names an agreement source. When the shape of the seam is itself in question — how deep the module is, where it belongs — consult the `codebase-design` skill.

## Tests

Test behavior through the seam: name the capability the caller gains, and take the expected value from an independent source — a known literal, a worked example, or the spec. Everything inside the seam runs real; when a test reaches a system boundary, read [mocking.md](references/mocking.md).

Name tests in the project's domain vocabulary: read `docs/agents/domain.md` when it exists, otherwise the relevant `CONTEXT.md` and the ADRs in the area you are touching.

Three smells, the first two with paired bad and good examples in [tests.md](references/tests.md); read it when a test's shape is in doubt:

- **Implementation-coupled** — mocks internal collaborators, tests private methods, or verifies through a side channel.
- **Tautological** — recomputes the expected value the way the code does.
- **Horizontal slicing** — writes tests in bulk instead of one **tracer bullet** at a time.

## Loop

Run the loop once per behavior, in the order the behaviors build on each other:

1. **Red.** Write one failing test at the agreed seam and run it. Done when it fails on the missing behavior, not on a setup or compile error. If it passes, the behavior already exists: correct a test that misses the intended behavior, otherwise record the existing coverage and skip Green.
2. **Green.** Write only the implementation that test needs. Done when the new test and the existing suite pass.
3. **Refactor.** Improve the design behind the seam. Done when the suite is still green.

**Complete when:** every agreed behavior is covered by a passing test at its seam, and the suite is green after the final refactor.

Report at handoff: `Behaviors: <covered>/<agreed> at their seams; Refactor: <change or none>; Suite: <command> → <result>`. When the runner cannot run or a loop needs a dependency or decision you lack, stop and report `Blocked: <behavior>; <symptom>; needs <dependency or decision>`.
