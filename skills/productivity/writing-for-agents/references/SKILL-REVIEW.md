# Creating and reviewing a skill

The procedures of [`writing-for-agents`](../SKILL.md) for the two moments a skill is judged as a whole: bringing a new one into being, and reviewing an existing one. Both end on the checklist below. The universal writing levers live in `SKILL.md`; the format rules in [`SKILL-MECHANICS.md`](SKILL-MECHANICS.md).

## Contents

- [Creating a skill](#creating-a-skill)
- [Reviewing a skill](#reviewing-a-skill)
- [Checklist](#checklist): frontmatter, structure, instructions, workflows, scripts and tools, evaluation

## Creating a skill

Evaluations first, instructions second: a skill written before its evaluations documents imagined problems.

1. **Find the gap.** Run the task without a skill on one representative case. Record where the agent fails and which context you keep re-supplying. Iterate on that one hard case until it succeeds; the context that made it succeed is the skill's raw material.
2. **Write three evaluations** to `evals/evals.json` in the skill directory, one per gap found, each with a recorded baseline:

   ```json
   {
     "skill_name": "<name>",
     "evals": [
       {
         "id": 1,
         "prompt": "The task as the user would type it",
         "files": ["evals/files/input.md"],
         "expected_output": "One sentence on what success looks like",
         "expectations": [
           "Checkable statement about the output or the agent's actions",
           "Another checkable statement"
         ],
         "baseline": "What the agent did without the skill",
         "runs": [
           {
             "date": "2026-01-31",
             "host": "Claude Code",
             "model": "claude-fable-5-1",
             "result": "pass",
             "notes": "Which expectations failed and how, or empty"
           }
         ]
       }
     ]
   }
   ```

   `runs` is optional and holds one entry per fresh-session test from step 5; `result` is `pass` only when every expectation held.

3. **Write the minimum that passes them.** Frontmatter per `SKILL-MECHANICS.md`, body per the levers in `SKILL.md`.
4. **Measure and check.** Run `scripts/measure.sh <skill-dir>` from this skill's directory, then the checklist below; fix every FAIL and every failed item, and re-run both until measure.sh prints no FAIL and every item passes.
5. **Test in a fresh session** on the evaluations, with every model and host the skill will run on, and append each run to the evaluation's `runs`. Done when every expectation holds on each. The smallest model exposes missing guidance; the largest exposes over-explaining. Watch how the agent navigates: a reference it never opens is unsignalled or unnecessary, one it opens every run belongs in `SKILL.md`, one it previews with `head` is nested too deep.
6. **Iterate from what step 5 showed,** and bump `metadata.version` with each behaviour change.

## Reviewing a skill

1. **Measure.** Run `scripts/measure.sh <skill-dir>` from this skill's directory; its output fills the report's `Measured` line.
2. **Run the checklist** top to bottom. Every item is pass or fail, with the line it fails on.
3. **Read for the levers in `SKILL.md`:** pointer wording, information hierarchy, completion criteria, leading words, duplication, no-ops. Done when every file of the skill has been read against every lever and each finding carries a file and line.
4. **Report** in this format, then stop and wait for the user's go before changing a file:

   ```markdown
   ## Review: <skill-name>

   Measured: <body lines> lines, description <n> chars, validator <passed|failed>.

   ### Blocking
   <a host rejects the skill or the agent cannot act; "none" if empty>
   - `<file>:<line>` — <rule> — <fix>

   ### Behavioural
   <the agent will vary or skip>
   - `<file>:<line>` — <rule> — <fix>

   ### Pruning
   <duplication, no-ops, exposition>
   - `<file>:<line>` — <rule> — <fix>

   ### Passes
   <one line naming what already holds>
   ```

## Checklist

Pass or fail per item. The frontmatter rules and their limits are stated in `SKILL-MECHANICS.md`; the items here only name them.

### Frontmatter

- [ ] Directory and `name` match, obey the name constraints, and follow the collection's naming pattern.
- [ ] `description` is third person, states what and when, carries the user's own terms, and obeys the length and character constraints.
- [ ] `compatibility` declares every CLI, package, network need, or host the body assumes.
- [ ] `metadata.version` reflects the latest behaviour change.
- [ ] The invocation choice follows the default or names what must reach the skill on its own, and the switch is mirrored on every host (`SKILL-MECHANICS.md`, Invocation and Hosts).

### Structure

- [ ] `SKILL.md` body under 500 lines; detail disclosed to `references/`, `scripts/`, or `assets/`; no `README.md` inside the skill directory.
- [ ] Every reference file is linked directly from `SKILL.md`, one level deep, under a descriptive filename, with the condition for opening it.
- [ ] Reference files over 100 lines open with a table of contents.
- [ ] One term per concept throughout, matching the terms in the user's prompts and the codebase.
- [ ] No dated or time-sensitive statements; superseded behaviour sits in an "old patterns" section.

### Instructions

- [ ] Each instruction changes behaviour versus the default; exposition and rationale the agent already holds are cut.
- [ ] Freedom matches fragility: exact commands or a script where one wrong step is costly, heuristics where many paths succeed.
- [ ] One default per decision with a named escape hatch, never a menu of options.
- [ ] Output formats carry a template; style-sensitive output carries input/output examples.
- [ ] Failure cases name the symptom, the cause, and the action; each stop condition says what to report.
- [ ] Skills, this one included, are referred to by bare name; MCP tools as `Server:tool`.

### Workflows

- [ ] Steps are ordered and each ends on a checkable completion criterion.
- [ ] A long workflow opens by having the agent record its steps in the host's task list tool and mark each done, falling back to a progress checklist copied into its first response where the host has no task list tool.
- [ ] Decision points are explicit, condition then branch; a large branch is disclosed to its own file.
- [ ] Quality-critical steps loop: validate, fix, re-validate, proceed only on pass.

### Scripts and tools

- [ ] Each script reference says whether to execute it or read it.
- [ ] Scripts handle their own error cases and explain every constant.
- [ ] Deterministic checks run as scripts, not as prose the agent interprets.

### Evaluation

- [ ] `evals/evals.json` holds at least three evaluations: prompt, inputs, expectations, baseline.
- [ ] Tested in a fresh session on every target model and host.
- [ ] Navigation observed and the findings fed back into the skill.
