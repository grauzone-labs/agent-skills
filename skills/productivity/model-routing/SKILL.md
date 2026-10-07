---
name: model-routing
description: Routes each requested deliverable to its assigned model before any work starts or is delegated. Use when any task starts in any session.
license: MIT
compatibility: Requires a harness with a model-switch or session control. External fallback uses an installed and authenticated claude, codex, or GitHub Copilot CLI.
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "productivity"
---

# Model routing

At the start of every task, classify the requested deliverables and assign each to a model before doing the work or delegating it. For a mixed task, split it by deliverable and route each part independently. Classification is complete when every deliverable has exactly one row of the table below and one model.

## Route each task

| Deliverable | Model |
| --- | --- |
| Development implementation: maintained code, tests, fixtures, build, packaging, and CI, plus scripts and research needed to complete that implementation, excluding prose deliverables | GPT 6.1 Sol (`gpt-6.1-sol`); use GPT 6 Astra (`gpt-6-astra`) only under the Development escalation rule below |
| Prose shipped with a Development change: documentation, help text, comments, and docstrings | Claude Opus 5.5 (`claude-opus-5-5`), always |
| Independent prose documentation, code reviews, PR descriptions, specifications, independent research, issue writing, and substantive technical issue comments, with none of the work attached to a Development change | Claude Fable 5.1 (`claude-fable-5-1`), always |
| Other work: one-time scripts, commit messages and execution, routine issue triage, logistical issue comments, and work that is neither Development nor Authoring | GPT 6 Luna (`gpt-6-luna`), subject to the Other-work Astra rule below |

The rows are, in order, Development, attached Authoring, independent Authoring, and Other work.

## Classify boundaries

- Authoring includes Markdown outside test fixtures, even when a build, package, or release includes it. Route prose attached to a Development change separately from the implementation, even when both land in one change. Tests that assert help text remain Development.
- Routine issue triage means labelling, deduplicating, linking, and scheduling. Reproducing, investigating, or diagnosing a defect in this repository's software is Development, including when triage or code review discovers it.

## Escalate to Astra

For Development, use GPT 6 Astra (`gpt-6-astra`) when the work needs broad cross-module context, such as a large refactor or architecture change, or when GPT 6.1 Sol has not resolved a difficult software problem.

For Other work, use Astra only for complex software or integration reasoning, or after GPT 6 Luna has not resolved a difficult software problem.

Explain each escalation to the user before launching the escalated work. Return routine follow-up work to its assigned model. Authoring stays on its routed model at every scope.

## Apply user overrides

The user's explicit model choice overrides this routing for the work it covers. Apply it only to that scope; route any other deliverables normally.

## Execute the route

### 1. Identify the current harness and resolve the model

Use explicit session instructions or runtime information to identify the harness executing the current session. A wrapper such as T3 Code can use OpenCode underneath; use the underlying harness for session and model operations. Installed CLIs and configuration directories are evidence of available fallback tools, not proof of the active harness. If the active harness remains unknown, ask the user to identify it.

Inspect the harness's available tools, model catalog, and session controls. The IDs in the routing table identify the intended models; each harness may require a provider-qualified ID, alias, or different spelling, so resolve the assigned model to its catalog-confirmed identifier before attempting a switch or launch. Consult CLI help or installed configuration when the catalog lookup is unclear.

Treat `model not found` as a failed lookup in that interface, not proof that the model is unavailable throughout the harness. Check its provider namespace, catalog, and supported identifier, then retry with the verified identifier. Keep the assigned model; a harness fallback is not a model escalation.

**Complete when** the current harness, supported execution controls, and exact model identifier for the next attempt are known, or the attempt is recorded as unavailable.

### 2. Try execution paths in order

Use the first successful path:

1. **Current session.** If the session already uses the assigned model, continue. Otherwise use an exposed model-switch control to select it in the current session. A model switch is a harness control that changes the session's model; a slash command typed into a shell or a model named in a prompt is not one. A current session on any other model, a higher tier included, does not satisfy the route; without a switch control, go to path 2 or 3.
2. **Same-harness session.** If the current session cannot switch, search the harness for a suitable existing session and resume it. Start a sub-session only when no suitable session can be continued, through a delegation tool that accepts the assigned model explicitly.
3. **External CLI fallback.** Before launching a CLI, check the current sandbox's network and filesystem limits; a limit that blocks the CLI is this path's concrete failure. Choose this path from the original current harness:
   - **GitHub Copilot:** use the GitHub Copilot CLI directly as the final fallback. Copilot provides access to both Anthropic and OpenAI models through its own model catalog. Resolve the assigned model there and discover the installed invocation through CLI help. Skip provider-native CLIs in this branch; Copilot model access does not establish separate Claude or Codex authentication.
   - **Other harnesses:** discover an installed provider-native CLI: `claude` for Anthropic models or `codex` for OpenAI models. Check its help, model availability, authentication, and session-resume support. Resolve the model identifier in that harness, then search for a suitable session to resume before starting a new one.

A session is suitable when its context is accessible through supported resume or continuation controls, it covers the same repository and relevant topic, it can use the assigned model, and it is idle or its previous work has finished. A focused follow-up review of the same topic resumes its earlier review session when it meets these criteria. Give unrelated work, or work whose prior context cannot be accessed, a new session.

If a previous attempt already used the same CLI and execution path, retry only when a newly verified identifier or setting addresses the failure.

At each switch or launch, select high reasoning effort when supported. Verify the active model from session metadata or the harness's launch result before performing the deliverable. If the requested model was explicitly selected but runtime verification is unavailable, record the gap and continue with the route marked unverified. If selection failed or metadata identifies a different model, try the next applicable path.

**Complete when** the deliverable has an execution session on the assigned model, verified or with the verification gap recorded. If every applicable path fails, pause that deliverable and report in your response to the user `Blocked: <deliverable>; Attempts: <harness/path and concrete failure for each>; Needed: <access to assigned model or explicit choice of an available model>`. Ask the user for the needed access or choice.

### 3. Hand off and collect the result

Before the deliverable starts, write its route in your response to the user in this form:

```
<deliverable> -> <model ID> (<verified from session metadata or launch result, or the gap>) on <harness>, effort <setting or unsupported>, session <identifier or none>
```

When the current session runs the assigned model, perform the deliverable yourself. Otherwise give the worker only its assigned deliverable, its route, and any user model override that covers it, and identify the expected result or artifact paths. For a resumed session, pass the new deliverable, the current source or diff, changes since its last run with superseded decisions or findings marked, and any updated constraints or completion criteria; it reuses its existing context as background and verifies prior claims against the current artifacts. For a new session, add the repository path and the relevant task context. Crossing harnesses requires an explicit handoff; session history is shared only when an available tool actually exposes or imports it. Keep file edits for the same deliverable under one session's ownership at a time.

**Complete when** each deliverable's result is collected and its artifacts inspected, and your final reply repeats every route line.
