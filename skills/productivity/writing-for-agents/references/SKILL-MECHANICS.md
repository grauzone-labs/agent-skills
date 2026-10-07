# Skill mechanics

The skill-specific branch of [`writing-for-agents`](../SKILL.md): what changes when the document is a skill — frontmatter, the invocation choice, and router skills. Everything else about writing it is the universal reference in `SKILL.md`; the procedures for creating and reviewing a skill are in [`SKILL-REVIEW.md`](SKILL-REVIEW.md).

## Format baseline

For every skill you create or edit, use the [Agent Skills specification](https://agentskills.io/specification) as the minimum format contract: a directory named for the skill with a `SKILL.md` containing YAML frontmatter and Markdown instructions. Apply collection and host-specific conventions only as additions to that baseline. `scripts/measure.sh` runs the reference validator, `skills-ref validate <skill-dir>` (through npx when it is not installed), which rejects fields outside the specification. `disable-model-invocation` is the one rejection this collection accepts deliberately, and a new host field earns its place only when a host reads it (see [Hosts](#hosts)).

## Frontmatter fields

Hosts validate `name` and `description` before loading, so a violation is a blocking defect, not a style note:

- **`name`** — the directory name: lowercase letters, digits, and hyphens; at most 64 characters; never containing `anthropic` or `claude`. Hold one naming pattern across a collection (verb-first, gerund, or noun) so skills are easy to refer to.
- **`description`** — non-empty, at most 1,024 characters, no angle brackets. Third person throughout ("Implements…", never "Implement…" or "I can…"): it is spliced into the system prompt beside every other skill's description, and a shift of voice there breaks discovery. The content follows the pointer rules in `SKILL.md`: what the skill does, then the trigger branches in the terms the user actually types. When a neighbouring skill owns the borderline cases, name it, so the agent reaches the right one.
- **`compatibility`** (optional, 1–500 characters) — every CLI, package, network need, or host the body assumes.
- **`metadata`** (optional, free keys) — `author`, `version`, `category` here; bump `version` with every behaviour change.
- **`license`** and **`allowed-tools`** (optional) — the latter declares pre-approved tools where the host supports it; enforcement is host-specific.

Use plain text without angle brackets throughout the frontmatter. In the body, keep placeholders such as `<id>` inside code spans.

## Invocation

Two choices, trading the two loads:

- A **model-invoked** skill shows its `description` to the agent, so the agent can fire it autonomously — and other skills can reach it. You can still type its name: a description adds agent discovery on top of the human's reach. The description is the skill's top-level context pointer, forced to stay loaded at all times — permanent context load in exchange for discoverability. A model-invoked skill whose content is all reference is also one home for shared reference: another skill can invoke it, so reference needed by several skills lives in one place. Mechanics: omit `disable-model-invocation`, set `policy.allow_implicit_invocation: true` in `agents/openai.yaml`, and write a model-facing description carrying the trigger branches.
- A **user-invoked** skill requires explicit invocation on hosts that honour its switch. On hosts that hide its description this saves context load, but it spends cognitive load — you are the index that must remember it exists. Mechanics: set `disable-model-invocation: true` and mirror it as `policy.allow_implicit_invocation: false` in `agents/openai.yaml`. The `description` stays model-facing: the other hosts show it to the agent anyway (see [Hosts](#hosts)), so lead with the one-line summary a human scans in a menu and keep the trigger branches behind it.

Default to user-invoked; pick model-invocation only when the agent must reach the skill on its own, or another skill must.

Shared reference that two user-invoked skills both need can live in neither — on a host that honours the switch, neither can fire the other. Push it to a plain file outside the skill system: external reference any skill can point at.

## Hosts

These skills load into Claude Code, Codex, OpenCode and Hermes Agent. All four ignore frontmatter fields they do not read, so a host-specific field is harmless elsewhere — and only the host that reads it changes behaviour:

| Host | Invocation switch | Description reaches the agent |
| --- | --- | --- |
| Claude Code | `disable-model-invocation` in `SKILL.md` | only when model-invoked |
| Codex | `policy.allow_implicit_invocation` in `agents/openai.yaml` | always; `false` only stops implicit invocation |
| OpenCode | none per skill | always |
| Hermes Agent | none per skill | always |

One consequence: refer to another skill by its bare name — "the `grilling` skill" — because the name is the one handle every host resolves, while invocation syntax (`/name`, `$name`, a skill tool) differs per host.

## Splitting by invocation

The invocation cut of splitting (the sequence cut lives in `SKILL.md`): split off a model-invoked skill when you have a distinct leading word that should trigger it on its own — one you actually use in your prompts — or another skill must reach it. You pay context load for the new always-loaded description, so that independent reach has to be worth it.

## Router skills

When user-invoked skills multiply past what you can remember, that piled-up cognitive load is cured by a **router skill**: one user-invoked skill that names the others and when to reach for each, so the human has one skill to remember instead of many. It can only hint, never fire them: on a host that honours the switch, only the human can reach a user-invoked skill.
