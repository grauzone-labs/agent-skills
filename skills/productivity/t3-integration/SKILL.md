---
name: t3-integration
description: Uses T3 Code's internal MCP server for model routing, delegated tasks, PR tracking, browser verification, HTML reports, and worktree binding. Use when a workflow runs in T3 Code or exposes t3-code tools; preserves the calling skill's existing workflow when a capability is unavailable.
compatibility: Uses the optional t3-code MCP server. ACP transport needs bash and T3's injected executable variables. Non-T3 fallbacks retain the calling skill's prerequisites.
license: MIT
metadata:
  author: "Sascha Grau"
  version: "1.0.3"
  category: "productivity"
---

# T3 integration

Shared reference for skills that run in T3 Code. Use only the branch needed by the current operation; the calling skill still owns scope, model policy, approval gates, output artifacts, and verification criteria. This skill is model-invoked because other skills reach it at those branch points.

## Discover and select a fallback

Use runtime instructions and exposed tools to identify T3. Outside T3 with no T3 evidence, follow the calling skill's existing workflow without probing for T3. In T3, discover the relevant tool's live contract; normalized MCP prefixes do not change its identity.

If a tool scan omits T3, attempt `t3-code:orchestrator_capabilities` once before declaring it absent. Where tools are not exposed and `T3_ACP_MCP_NODE` exists, execute the supported transport, preserving the optional entrypoint:

```bash
ELECTRON_RUN_AS_NODE=1 "$T3_ACP_MCP_NODE" ${T3_ACP_MCP_ENTRYPOINT:+"$T3_ACP_MCP_ENTRYPOINT"} acp-mcp-call orchestrator_capabilities '{}'
```

Other T3 tools use the same transport with their tool name and JSON arguments. Pass JSON through a file or safely quoted argument; model text must not become shell code. Use this only as T3's transport, not as a provider CLI fallback.

Choose fallback per operation. Confirmed missing/unsupported capabilities take the existing path; report the limitation. A permission denial, authentication failure, or invalid argument is an operation failure: correct an actionable argument or report the failure, preserving completed work. An accepted task, wait timeout, or uncertain dispatch is not unavailability: retain the task/request IDs and resolve its state before retrying. Never duplicate an accepted task or a successfully created PR through another path.

If this skill is missing from a selective installation, state the missing dependency, follow authoritative session/tool instructions where sufficient, and retain applicable existing paths. Do not block unrelated operations or bypass a permission failure.

**Complete when:** the required capability is callable, or its observed limitation and the applicable existing path are identified.

## Branch references

- For model selection, delegation, async completion, review rounds, or workspace binding, read [ORCHESTRATION.md](references/ORCHESTRATION.md).
- For creating, adopting, monitoring, or handing back a PR, read [PULL-REQUESTS.md](references/PULL-REQUESTS.md).
- For interactive browser verification, screenshots, recordings, or inline HTML, read [PRESENTATION.md](references/PRESENTATION.md).
