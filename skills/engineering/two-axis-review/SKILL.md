---
name: two-axis-review
description: Two-axis review of a change set against repository standards and its originating spec, each axis in its own sub-agent, reported separately. Use when reviewing a diff, branch, or pull request before merge; takes the fixed point and an optional spec path as arguments.
compatibility: Requires git and a host that can run parallel sub-agents; fetching issues needs network access and the tracker tool named in docs/agents/issue-tracker.md.
license: MIT
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "engineering"
---

# Two-axis review

Two-axis review of the change set since a fixed point through the current working tree:

- **Standards** — does the code conform to the repository's standards sources?
- **Spec** — does the code faithfully implement the originating spec?

## Process

When a git command, a read, a fetch, or a sub-agent fails, report `Blocked: <operation>; cause: <observed error>; needed: <recovery action>` and stop. A failed lookup is not an absence: only a confirmed absence takes an absence branch.

### 1. Pin the change set

The fixed point is what the user named — a commit SHA, branch name, tag, `main`, `HEAD~5`. Without one, ask for it. Confirm it resolves to a commit with `git rev-parse --verify <fixed-point>^{commit}`; when it does not, report the git error and ask for another.

Capture the merge base once: `git merge-base <fixed-point> HEAD`. The change set is:

- tracked changes, committed and work-in-progress: `git diff <merge-base>`
- untracked files: `git ls-files --others --exclude-standard`, each reviewed as an added file

Record the full commit messages against the same merge base: `git log <merge-base>..HEAD`. When every part of the change set is empty, report that nothing has changed since the fixed point and stop.

### 2. Identify the spec source

Look for the originating spec in this order and take the first hit:

1. A path the user passed as an argument.
2. Issue references in the recorded commit messages, subject or body (`#123`, `Closes #45`). When found, fetch them by the tracker contract in `docs/agents/issue-tracker.md`; when that file is absent, continue with the remaining sources.
3. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. Ask the user where the spec is, or whether there is one.

**Complete when:** the spec contents are in hand, or the user has confirmed there is none.

### 3. Gather standards

Find every standards source: each repository file that governs how code is written, such as `CODING_STANDARDS.md`, `CONTRIBUTING.md`, or a nested `AGENTS.md`, and note the directory each governs. Beneath them sits the baseline in [smells.md](references/smells.md); it goes to the Standards sub-agent in step 4.

### 4. Spawn the sub-agents and wait

Start this step once step 2 is complete. Spawn both sub-agents in parallel (on Claude Code, issue both Agent calls in the same message), then wait for every spawned sub-agent to return its report, keeping the turn open while one runs. Both prompts include the change-set commands and the recorded commit messages from step 1.

**Standards sub-agent prompt** — include:

- The standards-source files with the directory each governs, and the full text of `references/smells.md`.
- The brief: "Report — per file/hunk where relevant — (a) every place the diff breaks a standards source governing the file: cite the file and the rule, labelled a hard violation; and (b) every baseline smell: name it and quote the hunk, labelled a judgement call. Skip what the repository's configured tooling enforces. Under 400 words."

**Spec sub-agent prompt** — include:

- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that the spec did not ask for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding; for scope creep, quote the nearest scope statement or say the spec is silent. Under 400 words."

Without a spec, spawn the Standards sub-agent alone.

### 5. Aggregate

Return the reports verbatim or lightly cleaned, a report over 400 words trimmed to 400, each under its own heading and in its own order, then one summary line with the findings count and worst issue per axis, ranked within the axis only; without a spec, the Spec axis reads `not reviewed`:

```markdown
## Standards

<Standards report>

## Spec

<Spec report, or "No spec available.">

Standards: <n> findings, worst: <one line, or "none">. Spec: <n findings, or "not reviewed">, worst: <one line, "none", or "not reviewed">.
```

**Complete when:** every changed and untracked file has been reviewed against every standards source governing it and, when available, the spec, and the output follows the template above.
