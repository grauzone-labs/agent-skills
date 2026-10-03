# UI prototype

Generate **several radically different UI variations** on one route, switchable from a floating bottom bar. The user flips between variants in the browser, picks one (or combines elements), then the validated design is implemented properly.

For a question about logic or state transitions, return to [SKILL.md](../SKILL.md) and take its logic branch.

## Choose the host shape

A UI prototype is easiest to judge beside real header, navigation, data, and density. Prefer an existing page whenever one can host the prototype.

### A. Adjustment to an existing page — preferred

Keep the existing route, data fetching, parameters, and auth. In development, only the rendered subtree swaps through `?variant=`. Use this shape for a new section, card, or step that naturally belongs inside an existing page.

### B. New page — only when necessary

Use a clearly named throwaway route only when the prototype has no sensible host page. Follow the project's routing convention and use the same `?variant=` pattern. Before choosing this shape, establish that embedding it in an existing page would hide rather than reveal the relevant design constraint.

## Process

### 1. State the question and choose the set

Default to **three** variants; five is the maximum. Write one line at the prototype location or in a top-of-file comment naming the question, host route, and URL contract, for example:

> "Three variants of the settings page, available in development through `?variant=A|B|C` on `/settings`."

This step is complete when a reviewer can identify the page, the question, and every supported variant URL from that line.

### 2. Generate structurally different variants

Give every variant a clear exported component name, such as `VariantA`, `VariantB`, and `VariantC`. Use the project's existing component library and styling system.

Make each variant disagree about layout, information hierarchy, or primary affordance. A shared header is fine; each variant owns enough of its layout to test a genuinely different answer. This step is complete when every pair differs structurally rather than by colour or copy alone.

### 3. Gate and wire the route

Use a single switcher on the prototype host. Treat the entire prototype selection as development-only:

- For an existing page, production always renders the pre-existing subtree. It ignores `?variant=` and exposes neither alternative renderers nor the switcher.
- For a new prototype route, make the route unavailable outside the intended development environment.
- In development, accept only declared variant keys. Normalize a missing, invalid, or stale key to the default valid key so every shared URL renders a complete page.

Adapt this shape to the project's framework:

```tsx
const variants = { A: VariantA, B: VariantB, C: VariantC };
const prototypeEnabled = process.env.NODE_ENV !== 'production';
const requested = searchParams.get('variant');
const key = requested && requested in variants ? requested : 'A';
const Variant = variants[key];

return prototypeEnabled ? (
  <>
    <Variant {...data} />
    <PrototypeSwitcher variants={variants} current={key} />
  </>
) : (
  <ExistingPageContent {...data} />
);
```

Keep existing data fetching above the switcher; only the development subtree varies. This step is complete when each valid URL selects one variant, invalid URLs normalize to the default, and production retains the original route behavior.

### 4. Build the floating switcher

Put the switcher in one shared component, wherever shared UI belongs in the project. Render it only while the development prototype is enabled. It has:

- a left arrow that cycles to the previous variant and wraps;
- a label with the current key and optional variant name, such as `B — Sidebar layout`; and
- a right arrow that cycles forward and wraps.

Update the URL search parameter through the framework router so a selection is shareable and reload-stable. Support left and right arrow keys unless an `<input>`, `<textarea>`, or `[contenteditable]` has focus. Style the control as a visually distinct fixed bar at the bottom centre of the viewport.

This step is complete when pointer and keyboard controls cycle through every declared variant without taking over text-entry keys.

### 5. Verify and hand it over

Start the prototype using its documented project command. Open every valid variant URL, then an invalid variant URL, and confirm the declared default is rendered. Verify the switcher cycles in both directions, keyboard behavior preserves text entry, and a production build or equivalent production-mode run preserves the non-prototype route behavior. Surface the route URL and supported variant keys to the reviewer.

### 6. Capture the answer and clean up

Once a design wins, record which variant won and why, then preserve the complete set as [SKILL.md](../SKILL.md) describes. Implement the winner under the project's normal production standards. For an existing-page prototype, keep only the resulting production subtree in main. For a new-route prototype, promote the resulting design to its real route. Preserve the variants and switcher together on the throwaway branch as the prototype's primary source.
