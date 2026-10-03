# HTML report format

This reference defines the presentation for the architecture-review report. The report is one HTML file in the OS temp directory. It loads Tailwind and Mermaid from CDNs, so opening it requires network access to those providers. Mermaid communicates graph-shaped relationships; hand-built HTML/CSS/SVG carries editorial structure such as mass diagrams and cross-sections.

## Scaffold

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Architecture review — {{repo name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## Header

Show repository name, date, and a compact legend:

- solid box: module
- dashed line: seam
- red arrow: leakage
- thick dark box: deep module

Move directly from the header into the candidates.

## Candidate card

Render each candidate as one `<article>`.

- **Title** — short, names the deepening; for example, “Collapse the Order intake pipeline”.
- **Badge row** — recommendation strength (`Strong` in emerald, `Worth exploring` in amber, `Speculative` in slate) and the dependency category from `DEEPENING.md` (`In-process`, `Local-substitutable`, `Remote but owned (Ports & Adapters)`, or `True external`).
- **Evidence** — a monospaced list of the involved files and the observed code paths or test seams.
- **Before / After** — side-by-side visualisation as the centrepiece.
- **Problem** — one sentence naming the observed friction.
- **Deepening** — one sentence naming the responsibility and seam that would concentrate behavior.
- **Wins** — concise bullets naming the resulting locality, leverage, or test-surface gain.
- **ADR callout** — when applicable, an amber box that names the ADR and the evidence for reopening it.

Make diagrams self-explanatory enough that Problem and Deepening remain one sentence each. Preserve the selected domain terms and use the `codebase-design` vocabulary when describing architectural roles and outcomes.

## Diagram patterns

Choose the pattern that makes each candidate's evidence legible. Use visual variety where the structure changes.

### Mermaid graph

Use a Mermaid `flowchart` or `graph` for dependencies and call flow. Wrap it in a Tailwind-styled card. Use `classDef` to show leakage in red and the deep module in dark slate.

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
  </pre>
</div>
```

Use a sequence diagram when the comparison is round trips before and after.

### Hand-built boxes and arrows

Use positioned module `<div>` elements and inline SVG lines when the after-state benefits from a thick, deep outer module with subdued internal detail.

### Cross-section

Stack horizontal bands (`h-12 border-l-4`) for a call moving through many shallow layers. The after-state is a single substantial band carrying the consolidated responsibility.

### Mass diagram

Use two rectangles per module: interface surface and implementation. In the before-state, their visual mass is similar; in the after-state, a short interface fronts a substantial implementation.

### Call-graph collapse

Show a before-tree of calls as nested boxes. In the after-state, place the same calls as faded internals within one deep module.

## Visual style

Use an editorial layout: generous whitespace, stone/slate base colors, and one accent such as emerald or indigo. Red communicates leakage and amber communicates ADR reconsideration. Keep each diagram about 320px tall so before/after comparisons remain visible together. Use `text-xs uppercase tracking-wider` for module labels in diagrams.

Write sparse, plain evidence-led prose. Wins should name concrete gains, for example:

- `locality: bugs concentrate in one module`
- `leverage: one interface, N call sites`
- `interface shrinks; implementation absorbs the wrappers`

## Top recommendation

When one or more evidence-backed candidates exist, end with one larger card: candidate name, a one-sentence evidence-based reason it ranks first, and an anchor link to its candidate card. When none exist, omit this section and present the examined scope and evidence gaps instead.
