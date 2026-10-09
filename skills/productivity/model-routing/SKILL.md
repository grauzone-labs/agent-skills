---
name: model-routing
description: Routes each requested deliverable to a model and reasoning effort by its task category before any work starts or is delegated, applying repository and user overrides. Use when any task starts in any session.
license: MIT
compatibility: Requires a harness with a model-switch or session control. External fallback uses an installed and authenticated claude, codex, or GitHub Copilot CLI.
metadata:
  author: "Sascha Grau"
  version: "1.3.0"
  category: "productivity"
---

# Model routing

At the start of every task, classify each requested deliverable into one category by its purpose. Then resolve its route, the model and reasoning effort that perform it, and assign that route before doing the work or delegating it. Classification is complete when every deliverable has exactly one category and one route.

## Categories and built-in defaults

| Category | Purpose | Model | Effort | Escalation model | Escalation effort |
| --- | --- | --- | --- | --- | --- |
| `summarize` | Condense existing material without adding judgement: threads, commit lists, meeting notes | `claude-haiku-5-5` | high | `claude-sonnet-5-5` | high |
| `transform` | Change the structure or format of existing content without changing its meaning: extraction, reformatting, normalisation | `gpt-6-luna` | high | `gpt-6.1-sol` | medium |
| `translate` | Change the language of existing text without rewriting its content | `claude-sonnet-5-5` | medium | `claude-sonnet-5-5` | high |
| `write` | Prose for readers: documentation, guides, READMEs, release notes, PR descriptions, issue text, substantive comments, editing | `claude-sonnet-5-5` | high | `claude-opus-5-5` | high |
| `research` | Gather facts with their sources from code, documents, or the web, without recommending | `gpt-6.1-sol` | high | `gpt-6.1-sol` | xhigh |
| `analyze` | Weigh options or evaluate evidence to reach a recommendation or decision | `gpt-6.1-sol` | high | `claude-opus-5-5` | xhigh |
| `plan` | Define what gets built and in what order: specifications, requirements, acceptance criteria, ticket breakdowns | `claude-opus-5-5` | high | `claude-opus-5-5` | xhigh |
| `architect` | Design how a system is structured, as a design deliverable: module boundaries, interfaces, data models, migration paths, ADRs | `claude-opus-5-5` | high | `claude-opus-5-5` | xhigh |
| `implement` | Change maintained code toward known target behaviour: features, refactors, tests, fixtures, build, CI, and writing scripts | `gpt-6.1-sol` | high | `gpt-6.1-sol` | xhigh |
| `debug` | Find and fix a failure whose cause is unknown: reproduce, diagnose, fix, verify | `gpt-6.1-sol` | high | `gpt-6.1-sol` | xhigh |
| `review` | Assess an existing artifact against criteria and report findings: code, PRs, specifications, documentation | `claude-opus-5-5` | high | `claude-opus-5-5` | xhigh |
| `operate` | Run tools and workflows with little content of their own: running scripts, commits and commit messages, pushes, CI, deploys, routine issue labelling, deduplicating, linking, and scheduling, logistical comments | `gpt-6-luna` | high | `gpt-6.1-sol` | medium |

This table is a fixed policy. Change a route through the overrides below, never by ranking models at run time. Its model IDs name model identities, not identifiers valid in every catalog; resolve them under [Execute the route](#execute-the-route).

### Classify boundaries

- Classify by what the deliverable is for, never by file type: a Markdown file can be `plan`, `architect`, `write`, or `review`.
- `research` ends in facts with sources; `analyze` ends in a recommendation or decision. Fact gathering that only feeds a requested recommendation stays inside the `analyze` deliverable.
- `plan` decides what gets built, in what scope and order, and how acceptance is checked; `architect` decides how the system is structured. A document doing both takes the category of the main question it answers.
- `implement` starts from known target behaviour, even when the agent must work out how to reach it. A refactor whose result is code is `implement` at any size; `architect` covers only a separate design deliverable, such as a design document or ADR.
- `debug` starts from a failure whose cause is unknown and includes the fix that resolves it; a defect whose cause is already known is `implement`.
- `review` assesses an existing artifact and reports findings. Fixing a finding is a new `debug` or `implement` deliverable.
- Writing a script is `implement`; running one is `operate`.
- Comments, docstrings, and help strings inside changed code belong to that code's deliverable. A standalone document beside it, such as a README section or user guide, is a `write` deliverable.
- Issue text that defines work to build is `plan`; other issue text and substantive technical comments are `write`.

### Split mixed tasks

Split a task into one deliverable per independently usable result, such as a user guide beside a feature or a review after an implementation, and route each one. Reading code, running tests or builds, and brief lookups that serve one deliverable stay inside it, on its route, without a model switch.

## Resolve each route

Take each deliverable's route from the first source that covers it:

1. The user's explicit model or effort choice for the scope it covers.
2. The repository override row for the deliverable's category.
3. The built-in row for the category.

### Read repository overrides

Before routing, read `docs/agents/model-routing.md` at the repository root. When the file is absent, or the session runs outside a repository, use the built-in rows with model access `auto` and the subscription burner disabled. Each row replaces the built-in row of its category for this repository; categories without a row keep their built-in route.

The file follows this template. The `Model access` line is `provider-native`, `github-copilot`, or `auto`; a file without the line uses `auto`. The `Subscription burner` line is `enabled` or `disabled`; a file without the line has the burner disabled. The table holds one row per overridden category; with no overrides, it keeps only its header and separator lines.

```markdown
# Model routing

Category overrides for the `model-routing` skill. A category without a row uses the skill's built-in default.

Model access: provider-native
Subscription burner: disabled

| Category | Model | Effort | Escalation model | Escalation effort |
| --- | --- | --- | --- | --- |
| <category> | <model ID> | <effort> | <model ID or none> | <effort or none> |
```

A row may name any model the harness can run, such as `claude-fable-5-1` or `gpt-6-astra`. `none` in both escalation cells turns escalation off for that category.

The file is invalid when a row names an unknown category, a category has more than one row, a cell is empty, exactly one escalation cell is `none`, or a `Model access` or `Subscription burner` line is repeated or has a value outside its list. Report each invalid line with its problem and ask the user how to correct it. Until the user answers, hold every deliverable while the access line is invalid, high-complexity deliverables while the burner line is invalid, and a deliverable whose category an invalid row names. Other deliverables route normally.

### Apply user overrides

The user's explicit model choice overrides routing for the work it covers; route any other deliverables normally. Use the effort the user named, or else the effort of the category's resolved row. Keep a user-chosen model through every attempt: when it fails, report the failure and ask the user instead of escalating.

An effort choice alone keeps the resolved model and fixes the effort for its scope: escalation and the subscription burner may change that scope's model, never its user-chosen effort.

### Escalate

Escalate a deliverable to its row's escalation model and escalation effort, keeping a user-chosen effort, only when one of these holds:

- **High complexity:** the deliverable needs broad cross-module context, its requirements leave several plausible solutions open, or a wrong result is costly to reverse, such as an irreversible operation, a public interface change, or a data migration.
- **Failure:** the routed model attempted the deliverable and did not resolve it, or its result failed verification.

A deliverable that lands in a durable file meets neither condition by that alone. Explain the condition to the user before launching the escalated work. A row whose escalation is `none` stays on its route; when its attempt fails, report the failure and ask the user for a model choice. Return routine follow-up work to the route it had before escalation. When the subscription burner is on, a high-complexity deliverable on a built-in route follows the burner below instead of its row's escalation.

### Use the subscription burner

The subscription burner is an optional routing policy that runs complex work on `claude-fable-5-1` first and falls back to `claude-opus-5-5` when the Fable subscription usage is exhausted. It is on when the repository file says `Subscription burner: enabled` or the user switches it on in the session; the user's explicit on or off for the session wins over the file. It spends subscription usage only on work the task already requires.

**Scope.** The burner applies only to a deliverable that meets the high-complexity condition under [Escalate](#escalate) and whose route comes from its built-in row. A user model choice and a repository override row keep their routes, and other deliverables keep their category routes.

The burner never runs over GitHub Copilot, a Copilot subscription included. When the model access is `github-copilot`, or the path that would run the deliverable uses Copilot, route it through its row's escalation with `burner not applied: GitHub Copilot not supported`, even when the user switched the burner on. Never move a deliverable off Copilot to make the burner apply.

**Route.** The burner replaces the deliverable's escalation: `claude-fable-5-1` first, then `claude-opus-5-5` on a usage limit, both at the same effort, explained to the user like an escalation. That effort is the user's effort for the scope; otherwise it is the category's built-in escalation effort, raised to high when lower. A burner route does not escalate again: when it fails for a reason other than a usage limit, report the failure and ask the user.

**Subscription path.** Run a burner route only on a provider-native Claude path, Claude Code or the `claude` CLI, whose claude.ai subscription sign-in is confirmed from auth status or session metadata. Report that evidence as the path and billing kind only, never tokens, email addresses, or account identifiers. When billing is API-based or unknown, or no applicable path under [Execute the route](#execute-the-route) confirms subscription access, route the deliverable through its row's escalation and record `burner not applied: <reason>` in its route line. Keep Fable and its Opus fallback on that same subscription path; never switch to API billing, buy credits, or turn on paid overage to get past a limit.

**Usage limit.** A usage limit is a provider quota signal on a confirmed subscription path, such as `Fable usage limit reached`, `You've reached your Fable limit`, a read-out of an exhausted usage window, or `model_requires_usage_credits`. Explicit quota-exhaustion content like this qualifies whatever status code carries it. An HTTP 429 by itself, a requests- or tokens-per-minute throttle, a network error, a safety refusal, or an unsolved problem is no usage limit; handle it under Execute the route or as a burner failure. Handle an ambiguous signal the same way, and report it without claiming a limit.

**Fallback.** When Fable reports a usage limit:

1. Tell the user that Fable reached its usage limit and that the deliverable continues on `claude-opus-5-5`, and record the failed Fable attempt.
2. Select and verify `claude-opus-5-5` at the same effort on the same subscription path, resuming a suitable session or starting one under Execute the route.
3. Hand off the current state: changed files and diff, completed actions such as commits, pushes, or deploys that must not run again, open checks, and findings so far. The Opus session verifies that state against the current files rather than the Fable session's history, and takes over file ownership only after the Fable session has stopped.

**Limit state.** Within the active or resumed session, remember each subscription path whose Fable usage is limited, with the reset time only when the provider states one. Route later burner deliverables on that path straight to `claude-opus-5-5`, with the source `burner fallback`, until a stated reset time has passed, a reset is observed, or the user asks to retry Fable. Without a stated reset time, set no timer and estimate none. A fresh session with no access to that state makes one real Fable attempt. Keep the state out of the repository and git, and schedule no retries. When `claude-opus-5-5` also reports a usage limit, report `Blocked` as under Execute the route and stay off Fable.

## Execute the route

### 1. Identify the current harness and resolve the model

Use explicit session instructions or runtime information to identify the harness executing the current session. A wrapper such as T3 Code can use OpenCode underneath; use the underlying harness for session and model operations. Installed CLIs and configuration directories are evidence of available fallback tools, not proof of the active harness. If the active harness remains unknown, ask the user to identify it.

Inspect the harness's available tools, model catalog, session controls, and effort settings, and settle the model access:

- `provider-native` runs Anthropic models through Anthropic access and OpenAI models through OpenAI access, never through Copilot.
- `github-copilot` runs every model through GitHub Copilot: a Copilot provider in the current harness or the GitHub Copilot CLI, confirmed by its catalog. It never launches `claude` or `codex`.
- `auto` takes the access of the path that actually runs the deliverable.

The setting decides which paths this repository's routes may use; it does not change which harness runs the current session. Use the current session only when its model access matches; otherwise take a compatible session or CLI.

The IDs in a route identify the intended models. Each access and harness may require a provider-qualified ID, alias, or different spelling, and Copilot catalog IDs often differ from first-party ones. Resolve the assigned model, a user-supplied ID included, to its catalog-confirmed identifier in the chosen access at every switch, launch, and fallback, burner fallback included. Accept only an entry for the same model and version: never guess an alias, substitute another version, or pass a Copilot ID to a provider-native CLI. Consult CLI help or installed configuration when the catalog lookup is unclear.

Treat `model not found` as a failed lookup in that interface, not proof that the model is unavailable throughout the harness. Check its provider namespace, catalog, and supported identifier, then retry with the verified identifier. Keep the assigned model; a harness fallback is not a model escalation.

**Complete when** the current harness, the model access, supported execution controls, the exact catalog-confirmed model identifier, and the effort setting for the next attempt are known, or the attempt is recorded as unavailable.

### 2. Try execution paths in order

Use the first successful path:

1. **Current session.** If the session already uses the assigned model and effort, continue. Otherwise use exposed model-switch and effort controls to select them in the current session. A model switch is a harness control that changes the session's model; a slash command typed into a shell or a model named in a prompt is not one. A current session on any other model, a higher tier included, does not satisfy the route; without a switch control, go to path 2 or 3.
2. **Same-harness session.** If the current session cannot switch, search the harness for a suitable existing session and resume it. Start a sub-session only when no suitable session can be continued, through a delegation tool that accepts the assigned model explicitly.
3. **External CLI fallback.** Before launching a CLI, check the current sandbox's network and filesystem limits; a limit that blocks the CLI is this path's concrete failure. Choose this path by model access:
   - **GitHub Copilot,** when the access is `github-copilot`, or `auto` from a Copilot harness: use the GitHub Copilot CLI directly as the final fallback. Copilot provides access to both Anthropic and OpenAI models through its own model catalog. Resolve the assigned model there and discover the installed invocation through CLI help. Skip provider-native CLIs in this branch; Copilot model access does not establish separate Claude or Codex authentication.
   - **Provider-native,** when the access is `provider-native`, or `auto` from any other harness: discover an installed provider-native CLI: `claude` for Anthropic models or `codex` for OpenAI models. Check its help, model availability, effort settings, authentication, and session-resume support. Resolve the model identifier in that harness, then search for a suitable session to resume before starting a new one.

A session is suitable when its context is accessible through supported resume or continuation controls, it covers the same repository and relevant topic, it can use the assigned model and effort, and it is idle or its previous work has finished. A focused follow-up review of the same topic resumes its earlier review session when it meets these criteria. Give unrelated work, or work whose prior context cannot be accessed, a new session.

If a previous attempt already used the same CLI and execution path, retry only when a newly verified identifier or setting addresses the failure.

At each switch or launch, select the route's effort exactly as resolved: a `medium` route launches with medium, not the harness default. Verify the active model and effort from session metadata or the harness's launch result before performing the deliverable. If both were explicitly selected but runtime verification is unavailable, record the gap and continue with the route marked unverified. If selection failed or metadata shows a different model or effort, correct the launch with the verified setting or try the next applicable path. When an applicable path runs the assigned model but none supports the routed effort, use the nearest supported effort and record both in the route line before the deliverable starts.

**Complete when** the deliverable has an execution session on the assigned model and effort, verified or with the verification gap recorded. If every applicable path fails, pause that deliverable and report in your response to the user `Blocked: <deliverable>; Attempts: <harness/path and concrete failure for each>; Needed: <access to assigned model or explicit choice of an available model>`. Ask the user for the needed access or choice.

### 3. Hand off and collect the result

Before the deliverable starts, write its route in your response to the user in this form:

```
<deliverable> [<category>; <source>] -> <model ID> (<verification>) on <harness> via <model access>, effort <effort>, session <identifier or none>
```

- `<source>` is `built-in`, `repository override`, `user override`, `escalation`, `subscription burner`, or `burner fallback`. When the burner covers the deliverable but cannot run, append `; burner not applied: <reason>`.
- `<model access>` is `provider-native` or `github-copilot`, as settled for this route, and `<model ID>` is the catalog-confirmed identifier.
- `<verification>` is `verified from session metadata`, `verified from launch result`, or the recorded gap.
- `<effort>` is the active setting; `<setting> (routed <effort>, unsupported)` when the harness ran a nearer setting; or `unsupported` when the harness has no effort control.

When the current session runs the assigned model and effort, perform the deliverable yourself. Otherwise give the worker only its assigned deliverable, its route, and any user override that covers it, and identify the expected result or artifact paths. For a resumed session, pass the new deliverable, the current source or diff, changes since its last run with superseded decisions or findings marked, and any updated constraints or completion criteria; it reuses its existing context as background and verifies prior claims against the current artifacts. For a new session, add the repository path and the relevant task context. Crossing harnesses requires an explicit handoff; session history is shared only when an available tool actually exposes or imports it. Keep file edits for the same deliverable under one session's ownership at a time.

**Complete when** each deliverable's result is collected and its artifacts inspected, and your final reply repeats every route line.
