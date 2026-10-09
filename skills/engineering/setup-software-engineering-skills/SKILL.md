---
name: setup-software-engineering-skills
description: "Configures a repository's engineering-skill integration: issue tracker, triage labels, domain documentation, and model routing when available. Use when installing or setting up these skills in a repository, or when another skill reports that docs/agents/ configuration is missing."
compatibility: "Requires git. Uses gh on GitHub, glab and jq on GitLab, and az with the azure-devops extension on Azure DevOps, with network access to the chosen tracker."
license: MIT
disable-model-invocation: true
metadata:
  author: "Sascha Grau"
  version: "1.3.0"
  category: "engineering"
---

# Setup software engineering skills

## Table of contents

- [Process](#process)
  - [1. Explore](#1-explore)
  - [2. Present findings and ask](#2-present-findings-and-ask)
  - [3. Configure model routing](#3-configure-model-routing)
  - [4. Confirm target and draft](#4-confirm-target-and-draft)
  - [5. Write](#5-write)
  - [6. Done](#6-done)

Scaffold the per-repo configuration that the engineering skills assume:

- **Issue tracker** - where issues live and the operations the skills run against them
- **Triage labels** - the label strings for the seven canonical triage roles
- **Domain docs** - where `CONTEXT.md` and ADRs live, and the consumer rules for reading them
- **Model routing** - when `model-routing` is installed, a session-start pointer to it and the repository's model access, category overrides, and subscription burner setting in `docs/agents/model-routing.md`

A skill counts as **installed** when the target agent can load it: it is listed in the current skill catalog or present in the target project's or user's skill directories. A source copy in a distribution repository does not count.

## Process

Copy this checklist into the response and tick each item when its completion criterion holds:

- [ ] Explore
- [ ] Present findings and ask
- [ ] Configure model routing
- [ ] Confirm target and draft
- [ ] Write
- [ ] Done

### 1. Explore

Read what exists in the current repo:

- `git remote -v` - which host: GitHub, GitLab (`gitlab.com` or self-hosted), Azure DevOps (`dev.azure.com` or `*.visualstudio.com`), or none?
- For an Azure DevOps remote, or when the user supplies an organization/project, run the discovery procedure in [issue-tracker-azure-devops.md](references/issue-tracker-azure-devops.md): inventory the work item types with their states, required fields, and Parent/Child relations, recording the evidence and verification status of each separately. Run both the project query and the work-item-type query even when the first fails or is unauthenticated, then follow its failed-discovery procedure.
- `AGENTS.md` and `CLAUDE.md` at the repo root - does either exist, and does either already carry an `## Agent skills` section?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root
- `docs/adr/` and any `src/*/docs/adr/` directories
- `docs/agents/` - this skill's prior output
- `.scratch/` - a local-markdown issue tracker convention already in use
- Which of `triage`, `wayfinder`, and `model-routing` are installed. `triage` decides whether Section B runs; `wayfinder` decides whether Azure DevOps setup asks for a map type; `model-routing` decides whether step 3 runs and the routing pointer is written.
- Monorepo signals - a root `CONTEXT-MAP.md`, a `pnpm-workspace.yaml`, a `workspaces` field in `package.json`, or a populated `packages/*` with its own `src/`. Their absence means single-context, which is almost every repo.

**Complete when:** the tracker evidence, the existing agent configuration, the installed state of `triage`, `wayfinder`, and `model-routing`, and the context-layout signals are recorded or explicitly absent.

### 2. Present findings and ask

Summarise what is present and what is missing. Then take the sections in order - one section, one answer, then the next. Lead each section with the recommended answer so the user can accept it in a word; add a one-line explainer only when the choice genuinely branches. Skip a section that exploration already settled: Section B when `triage` is not installed, Section C when there are no monorepo signals.

**Section A - Issue tracker.** Propose the tracker the remote names: GitHub, GitLab, or Azure DevOps. With no remote, propose local markdown. With conflicting remotes or an unrecognised host, ask which tracker and repository to configure. When the user prefers another, the choices are:

- **Azure DevOps** - issues live in the repo's Azure DevOps project (uses the `az devops` CLI)
- **GitHub** - issues live in the repo's GitHub Issues (uses the `gh` CLI)
- **GitLab** - issues live in the repo's GitLab Issues (uses the [`glab`](https://gitlab.com/gitlab-org/cli) CLI)
- **Local markdown** - issues live as files under `.scratch/<feature-slug>/` in this repo (solo projects or repos without a remote)
- **Other** (Jira, Linear, etc.) - ask the user to describe the workflow in one paragraph; record it as freeform prose

The GitHub, GitLab, and Azure DevOps templates carry a "PRs as a request surface" flag that defaults to `no`; write it as it is, without asking - a user who wants external PRs in the triage queue flips it in the file later.

For Azure DevOps, present the discovery findings - confirmed scope, type inventory, state categories, hierarchy evidence, and verification gaps - and settle the mappings per **Settle workflow mappings** in [issue-tracker-azure-devops.md](references/issue-tracker-azure-devops.md): the user picks the available types that represent specifications and implementation tickets and, when `wayfinder` is installed, the map type and the decision-ticket type separately. Custom types such as `Specification` and `Wayfinder` are choices, never presumed. When a requested type is unavailable, ask the user to choose an available type or resolve the process configuration first.

**Section B - Triage label vocabulary.** Ask exactly one question:

> Do you want to keep the default triage labels? (recommended: **yes**)

The defaults are the table in [triage-labels.md](references/triage-labels.md). On **yes**, write them as-is. On **no** - usually because the tracker already uses other names, such as `bug:triage` for `needs-triage` - collect the overrides so `triage` applies the existing labels instead of creating duplicates.

**Section C - Domain docs.** An existing root `CONTEXT-MAP.md` settles **multi-context** without asking. Otherwise default to **single-context** - one `CONTEXT.md` plus `docs/adr/` at the repo root - and write it without asking. When exploration found other monorepo signals, offer **multi-context** - a root `CONTEXT-MAP.md` pointing to per-context `CONTEXT.md` files - and confirm which layout they want.

**Complete when:** every unresolved configuration branch has one user answer.

### 3. Configure model routing

Run this step only when `model-routing` is installed. Otherwise skip it: ask no access, routing, or burner question and write no `docs/agents/model-routing.md`.

Read the **Categories and built-in defaults** table and the **Use the subscription burner** section in the `SKILL.md` of the installed `model-routing` skill, the copy the target agent loads, and any existing `docs/agents/model-routing.md`.

Ask each question with the host's structured question tool, such as `AskUserQuestion`, `question`, `request_user_input`, or `request_user_input_async`. Only when the host has no such tool, ask in chat and say that the host offers no structured question tool. When the user already answered a question in this session, apply that answer instead of asking it again.

1. **Choose the model access.** Before any model question, ask one question with the options `Provider-native: Anthropic and OpenAI directly` and `GitHub Copilot`, naming the current `Model access` setting when the file has one. Take the answer from the user, never from the git remote, the issue tracker, or installed CLIs.
2. **Show the defaults.** Write a table in your response, as visible text, with all twelve rows of the defaults table: category, purpose, model, effort, and escalation. Below it, list any current override rows, labelled as such, and the current burner setting. Reading the skill or a tool result shows the user nothing, and a question that points to defaults "above" replaces no table. Under GitHub Copilot, the table's IDs name models, and Copilot may list them under other IDs: when a read-only Copilot catalog lookup is available, show the confirmed Copilot ID beside each model it lists; otherwise mark the IDs as unverified for Copilot, resolved by `model-routing` at run time. Keep every row either way. **Complete when** a response has shown the user all twelve rows with their purpose, model, effort, and escalation, plus any current overrides and the burner setting; only then ask the mode question.
3. **Choose the mode.** Ask one question with the options `Use defaults (recommended)` and `Customize`. **Use defaults** keeps no category override rows, current overrides included, and asks no per-category question.
4. **Customize each category.** Ask one question per category, in table order. Each question names the category, its purpose, its built-in route, and its current override when one exists. Offer `Default: <model> <effort>` and take a custom answer, which may repeat the current override, through the tool's free-text input. When the tool accepts free text only through an option, add a `Custom` option whose selection asks for the model ID and effort with no prefilled value. Put several categories into one call only when the tool supports several questions per call.
5. **Choose the burner.** Under GitHub Copilot, ask nothing: tell the user the subscription burner is not supported with GitHub Copilot and set it to disabled. Under provider-native access, summarise the burner rule from the installed skill, including that it runs only over a confirmed Claude subscription and never moves work to paid API billing. Then ask one question with the options `Standard routing (recommended)` and `Subscription burner: Fable first for complex tasks, Opus on usage limit`, naming the current setting. Ask it under either mode; a current `enabled` setting carries over only when the user chooses it again or already chose it in this session. The answer changes only the repository file, never the model of this setup session.

Turn the answers into the configuration template in the installed `model-routing` skill:

- **Provider-native** writes `Model access: provider-native`; **GitHub Copilot** writes `Model access: github-copilot`.
- **Default** adds no row.
- **Custom** takes the model ID as given and checks it against the chosen access's catalog when a read-only lookup is available; otherwise you tell the user the ID is unverified until run time. Without an effort, it takes the category's built-in effort, and you tell the user which effort you filled in. Its escalation cells are `none` unless the user names both an escalation model and an escalation effort.
- A custom answer identical to the built-in row adds no row. Ask that category again when the answer names no model ID, gives more than one effort level, or names an escalation model without an escalation effort.
- **Standard routing** and GitHub Copilot access write `Subscription burner: disabled`; the burner option writes `Subscription burner: enabled`.

A question that returns without the user's answer, such as an asynchronous tool's immediate return or a dismissed or closed question, leaves its choice pending. Report which choice is pending, wait for the user's reply, and start no draft until it is answered. Ask again only after the user replies or the session resumes, never in an immediate loop, and never treat a missing answer as a default.

**Complete when:** the step was skipped because `model-routing` is not installed, or a response has shown the user all twelve default rows before the mode question, and the model access, the mode, and, under provider-native access, the burner have user answers and, under **Customize**, every category has a default or custom answer turned into its row or no row.

### 4. Confirm target and draft

Pick the instruction file: `CLAUDE.md` when it exists, else `AGENTS.md` when it exists, else ask the user which one to create.

For GitHub and GitLab, resolve the template's setup-time values - target branch and merge method - with the lookups the template names before drafting. When a lookup fails, report the lookup, the cause, and the operations it affects; proceed only once it succeeds after recovery or the user accepts the value as a labelled gap with those operations blocked.

Show the user, in your response, the complete text of each item below, every section written out even where it matches the template:

- The `## Agent skills` block for the selected file
- `docs/agents/issue-tracker.md`, `docs/agents/domain.md`, and, when `triage` is installed, `docs/agents/triage-labels.md`
- `docs/agents/model-routing.md` when `model-routing` is installed, with the model access, burner setting, and rows from step 3. When the file already exists, also list each override the draft adds, changes, or removes, and any change to the model access or burner setting.

For Azure DevOps, the tracker draft is the complete contract described under **Generate the tracker contract** in [issue-tracker-azure-devops.md](references/issue-tracker-azure-devops.md), with each finding marked verified, user-selected, or explicitly accepted as unverified.

When the file already carries a model-routing instruction, keep it where it is and reconcile a conflicting one with the user here; the block then omits its `### Model routing` sub-block. Let them edit before writing.

**Complete when:** the user has approved the selected instruction file and the complete contents of every generated document. For Azure DevOps, every configuration value is confirmed or explicitly accepted as unverified, operations that depend on unverified values are documented as blocked until discovery succeeds, and unverified values appear as labelled gaps, never inside executable commands: each blocked operation is a prose line naming the operation, the unverified value, and its recovery lookup, with no command.

### 5. Write

When an `## Agent skills` block already exists in the chosen file, replace its contents in place; the surrounding sections stay as approved in step 4.

The block:

```markdown
## Agent skills

### Model routing

At the start of every session, before starting or delegating any task, load and apply the `model-routing` skill when available. Follow its model selection, harness fallback, and session-reuse rules.

### Issue tracker

[one-line summary of where issues are tracked]. Before creating or reading tickets, publishing specifications, changing hierarchy, triaging, wayfinding, or completing work, use the operations and mappings in `docs/agents/issue-tracker.md`.

### Triage labels

[one-line summary of the label vocabulary]. Before applying triage roles, use `docs/agents/triage-labels.md`.

### Domain docs

[one-line summary of layout - "single-context" or "multi-context"]. Before exploring domain behavior or naming domain concepts, use `docs/agents/domain.md`.
```

Include `### Triage labels`, and write `docs/agents/triage-labels.md`, only when `triage` is installed.

Include `### Model routing` as the first sub-block only when `model-routing` is installed and the file carries no other model-routing instruction. The routing rules stay in the skill; the instruction file carries only the pointer.

Then write the docs files from the seed templates in this skill folder. For GitHub, GitLab, and local markdown, copy every section of the chosen tracker template - its Implementation operations and Wayfinding operations are the contracts `implement-work-item` and `wayfinder` read later - and fill in its setup-time values:

- [issue-tracker-azure-devops.md](references/issue-tracker-azure-devops.md) - Azure DevOps issue tracker; generate the contract and its work-item templates from the discovery findings, per **Generate the tracker contract**
- [issue-tracker-github.md](references/issue-tracker-github.md) - GitHub issue tracker
- [issue-tracker-gitlab.md](references/issue-tracker-gitlab.md) - GitLab issue tracker
- [issue-tracker-local.md](references/issue-tracker-local.md) - local-markdown issue tracker
- [triage-labels.md](references/triage-labels.md) - label mapping
- [domain.md](references/domain.md) - domain doc consumer rules + layout

For "other" issue trackers, write `docs/agents/issue-tracker.md` from the user's description.

When `model-routing` is installed, write `docs/agents/model-routing.md` from the configuration template in that skill, with the approved model access, burner setting, and rows and no row for a category that keeps its built-in route. `model-routing` reads the file itself, so the instruction file gains no pointer to it.

**Complete when:** the instruction file and generated documents match the approved draft, their pointers resolve, executable tracker commands contain no unresolved configuration placeholders, accepted verification gaps and blocked operations are documented, and, when `model-routing` is installed, the model-routing pointer appears exactly once and `docs/agents/model-routing.md` holds exactly the approved model access, burner setting, and override rows.

### 6. Done

Report with this template, listing only the files written:

```text
Setup complete<, with verification gaps: <operation - reason and recovery>>
Instruction file: <path>
docs/agents/issue-tracker.md - <tracker>; read by triage, wayfinder, implement-work-item, to-tickets, to-spec, pr, and two-axis-review
docs/agents/triage-labels.md - read by triage, to-tickets, and to-spec
docs/agents/domain.md - <layout>; read by domain-modeling, tdd, diagnosing-bugs, to-tickets, and to-spec
docs/agents/model-routing.md - <provider-native or github-copilot>, <built-in defaults or the overridden categories>, subscription burner <enabled or disabled>; read by model-routing
Edit docs/agents/*.md directly later; rerun this skill only to switch issue trackers or restart from scratch.
```

**Complete when:** the report names every written file with its consumers, every accepted verification gap, and when to rerun setup.
