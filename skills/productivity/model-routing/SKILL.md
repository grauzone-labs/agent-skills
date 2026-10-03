---
name: model-routing
description: Before starting or delegating any task in every session, route each requested deliverable to its assigned model. Apply this to development, attached prose, independent authoring, research, issue work, scripts, and other tasks; split mixed deliverables and follow the escalation and user-override rules.
license: MIT
metadata:
  author: "Sascha Grau"
  version: "1.0.0"
  category: "productivity"
---

# Model routing

At the start of every task, classify the requested deliverables and assign each to a model before doing the work or delegating it. For a mixed task, split it by deliverable and route each part independently. Use high reasoning effort when starting a session or delegation.

## Route each task

| Deliverable | Model |
| --- | --- |
| Development implementation: maintained code, tests, fixtures, build, packaging, and CI, plus scripts and research needed to complete that implementation, excluding prose deliverables | GPT 6.1 Sol (`gpt-6.1-sol`); use GPT 6 Astra (`gpt-6-astra`) only under the Development escalation rule below |
| Prose shipped with a Development change: documentation, help text, comments, and docstrings | Claude Opus 5.5 (`claude-opus-5-5`), always |
| Independent prose documentation, code reviews, PR descriptions, specifications, independent research, issue writing, and substantive technical issue comments, with none of the work attached to a Development change | Claude Fable 5.1 (`claude-fable-5-1`), always |
| Other work: one-time scripts, commit messages and execution, routine issue triage, logistical issue comments, and work that is neither Development nor Authoring | GPT 6 Luna (`gpt-6-luna`), subject to the Other-work Astra rule below |

## Classify boundaries

- Development owns maintained code, tests, fixtures, build, packaging, CI, and scripts or research needed to implement that software change. GPT 6.1 Sol, or Astra only when escalated, performs this work.
- Authoring includes Markdown outside test fixtures, even when a build, package, or release includes it. Prose in maintained source, including help text, comments, and docstrings, is also Authoring. Route prose attached to a Development change separately from the implementation, even when both land in one change. Tests that assert help text remain Development.
- Independent Authoring has no Development change to accompany it.
- Routine issue triage means labelling, deduplicating, linking, and scheduling. Reproducing, investigating, or diagnosing a defect in this repository's software is Development, including when triage discovers it. A defect discovered during code review returns to Development.
- Independent scripts and research use their own rows. A script required to implement a Development change is Development; a one-time script unrelated to maintained implementation is Other work.

## Escalate to Astra

For Development, use GPT 6 Astra (`gpt-6-astra`) when the work needs broad cross-module context, such as a large refactor or architecture change, or when GPT 6.1 Sol has not resolved a difficult software problem.

For Other work, use Astra only for complex software or integration reasoning, or after GPT 6 Luna has not resolved a difficult software problem. Keep routine Other work on Luna.

Explain each escalation to the user. Return routine follow-up work to its assigned model. Escalation covers Development and Other work; Authoring stays on its routed model at every scope.

## Apply overrides and reuse sessions

The user's explicit model choice overrides this routing for the work it covers. Apply it only to that scope; route any other deliverables normally.

When routing requires a separate session, search the selected harness for an existing session with reusable context before creating one. Apply this to every deliverable and model. A focused follow-up review of the same topic should resume its earlier review session when that session is suitable.

A session is suitable when its context is accessible through supported resume or continuation controls, it covers the same repository and relevant topic, and it can use the assigned model. Confirm the working directory and current branch or diff; supply changes since the previous run and mark superseded decisions or findings. Reuse its context as background, then verify claims against the current artifacts. Give unrelated work or work whose prior context cannot be accessed a new session.

## Execute the route

### 1. Identify the current harness and resolve the model

Use explicit session instructions or runtime information to identify the harness executing the current session. A wrapper such as T3 Code can use OpenCode underneath; use the underlying harness for session and model operations. Installed CLIs and configuration directories are evidence of available fallback tools, not proof of the active harness. If the active harness remains unknown, ask the user to identify it.

Inspect the harness's available tools, model catalog, and session controls. Resolve the assigned model against that catalog before attempting a switch or launch. The IDs in the routing table identify the intended models; each harness may require a provider-qualified ID, alias, or different spelling. Use a catalog-confirmed identifier for the same model. Consult CLI help or installed configuration when the catalog lookup is unclear.

Treat `model not found` as a failed lookup in that interface, not proof that the model is unavailable throughout the harness. Check its provider namespace, catalog, and supported identifier, then retry with the verified identifier. Keep the assigned model; a harness fallback is not a model escalation.

**Complete when** the current harness, supported execution controls, and exact model identifier for the next attempt are known, or the attempt is recorded as unavailable.

### 2. Try execution paths in order

Use the first successful path:

1. **Current session.** If the session already uses the assigned model, continue. Otherwise use an exposed model-switch control to select it in the current session. Typing a slash command into a shell or naming a model in a prompt is not a model switch.
2. **Same-harness session.** If the current session cannot switch, first discover and resume a suitable related session using the reuse criteria above. Start a sub-session only when no suitable session can be continued, with the assigned model explicitly selected. A delegation tool without model selection does not establish that it runs the routed model.
3. **External CLI fallback.** Choose this path from the original current harness:
   - **GitHub Copilot:** use the GitHub Copilot CLI directly as the final fallback. Copilot provides access to both Anthropic and OpenAI models through its own model catalog. Resolve the assigned model there and discover the installed invocation through CLI help. Skip provider-native CLIs in this branch; Copilot model access does not establish separate Claude or Codex authentication.
   - **Other harnesses:** discover an installed provider-native CLI: `claude` for Anthropic models or `codex` for OpenAI models. Check its help, model availability, authentication, and session-resume support. Resolve the model identifier in that harness before resuming or starting a session.

If a previous attempt already used the same CLI and execution path, retry only when a newly verified identifier or setting addresses the failure.

At each switch or launch, select high reasoning effort when supported. If the harness lacks that setting, report the limitation. Verify the active model from session metadata or the harness's launch result before performing the deliverable. If the model cannot be verified, record that gap rather than claiming successful routing.

**Complete when** the deliverable has a verified execution session using the assigned model. If every applicable path fails, report the attempted harnesses and concrete failures, then ask the user to provide access or explicitly choose an available model.

### 3. Hand off and collect the result

For a resumed session, pass the new deliverable, current source or diff, changes since its last run, and any updated constraints or completion criteria. Use the existing context rather than rebuilding it from scratch. For a new session, provide the repository path and the relevant task context in addition to those inputs. Crossing harnesses requires an explicit handoff; session history is shared only when an available tool actually exposes or imports it.

Give a worker only its assigned deliverable and identify the expected result or artifact paths. Preserve task context when switching the current session. Continue an existing session only when it is idle or its previous work has finished; keep file edits for the same deliverable under one session's ownership at a time.

Record the selected harness, verified model ID, effort setting, and resumable session identifier when exposed. Wait for the worker's result and inspect its artifacts before reporting completion. Return subsequent deliverables and routine follow-up to their own routed models.
