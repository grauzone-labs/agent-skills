# Browser verification and HTML delivery

## Collaborative browser

For interactive browser work, first call `t3-code:preview_status`. If no automation-capable preview is attached, try `t3-code:preview_open` before declaring it unavailable. Navigate with `t3-code:preview_navigate`, inspect with `t3-code:preview_snapshot`, and use snapshot-provided locators for focused interaction tools. Read live argument schemas instead of assuming every tool accepts a URL or file path.

When the user refers to their open page, read the tab listed by status, including a human-owned tab, with `preview_snapshot` and its `tabId`. Interact only with your own tab or an unclaimed user tab. For a human-controlled tab, open a separate tab with `reuseExistingTab: false` for interaction; evaluation can mutate the page and follows the same ownership rule. Carry the returned `tabId` through every call. Parallel agents each need their own tab. Refresh snapshot locators after navigation, a new snapshot, or human takeover. Select saved logins only through a profile listed by status.

Capture user-visible screenshot evidence with `preview_snapshot` and `save: true`, then use its returned local path in the reply. For recordings use `t3-code:preview_recording_start` and `t3-code:preview_recording_stop`, retaining the returned evidence path. An image-only tool response is not a saved screenshot artifact.

Use the calling skill's existing browser path when T3 preview tools are absent, `preview_open` is explicitly unsupported/unavailable, or the user/project workflow explicitly selects another browser. Correct an actionable first error. If an open tab fails twice on the same step, quote the raw error and use the existing fallback without asking which browser to use. An initially closed preview or one failure alone does not trigger fallback. Preserve project test commands for repeatable automated regression tests; collaborative inspection complements them.

**Complete when:** the calling skill's interactions/checks pass and their evidence is saved, or the failed checks and observed browser limitation are handed back as its existing workflow requires.

## HTML reports and demos

Keep the calling skill's HTML artifact and content checks. When inline HTML delivery is available, use `t3-code:html_preview` on a self-contained document, inspect the screenshot and console, fix failures, then call `t3-code:html_render`. Follow the tool's live theme/layout contract; adapt an external-page scaffold to the inline frame, avoiding viewport-height layouts and an outer background/card. Preserve the report's candidate fields, diagrams, anchors, and other semantic requirements.

If preview explicitly reports first-run browser installation, retry once after the reported preparation interval. If preview or rendering remains unavailable, report that limitation and use the calling skill's existing desktop opener/path delivery. Never claim an inline render succeeded when it failed. Once rendered, final prose adds only information the report does not show. A PR description stays Markdown in its host; inline HTML is chat presentation, not a replacement for the PR body.

**Complete when:** the checked artifact is delivered inline with successful rendering, or through the existing delivery path with its limitation stated.
