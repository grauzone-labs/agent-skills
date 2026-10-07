# Logic prototype

A single, self-contained HTML file — a **shareable demo** — that lets anyone drive a state model by clicking buttons. Use it for a question about **business logic, state transitions, or data shape**. Write labels and outcomes in the reviewer's domain language.

For a question about appearance, return to [SKILL.md](../SKILL.md) and take its UI branch.

## Process

### 1. State the question

Write one visible paragraph at the top of the demo naming the state model and the question it answers. This is complete when a returning non-developer can tell what the demo is testing without reading its source.

### 2. Isolate the decision-rich logic

Put the logic answering the question in its own `<script>` element. Keep DOM access and event handlers in a separate page `<script>` element; the page calls the model's interface with domain values and renders its outcomes.

Default to **a pure reducer** — `(state, action) => state` for discrete events over a single state value. Switch shape only when the question demands it:

- **A state machine** — explicit states and transitions when legal actions are part of the question.
- **A small set of pure functions** over a plain data type for stateless transformations.
- **A class or module with a clear method surface** when the logic genuinely owns ongoing internal state.

This step is complete when the page can drive the model exclusively through that public surface, including the outcome and reason for each attempted action.

### 3. Build the shareable HTML file

Use one plain HTML/CSS/JS file with every dependency inline. It must open directly from the filesystem, without a framework, bundler, or server.

Lay it out top to bottom:

1. **Title and one-line explanation** — the question from step 1.
2. **Current state and latest outcome** — render the full relevant state as labelled fields rather than raw JSON. After every attempt, show whether the action was accepted or rejected, the domain-language reason, and what changed.
3. **Free play** — show every action as a button so a reviewer can try any sequence. Dispatch each attempt through the model and render its outcome, including rejected or illegal transitions.
4. **Guided walkthroughs** — provide walkthroughs as tabs. Each tab states the situation and what to watch for, then presents its ordered actions as real buttons. Starting a walkthrough resets to a known initial state. Include the happy path, an awkward edge case, and an action that should be illegal when those cases apply.

Use restrained visual hierarchy: clean typography, generous spacing, and one accent colour. This step is complete when every action visibly produces an accepted or rejected outcome and restarting each walkthrough restores its stated initial state.

### 4. Verify and hand it over

Open the HTML file directly from the filesystem. Complete every walkthrough and try every free-play action. Verify that the visible question, state, and latest outcome remain understandable without developer context. Fix every failure and repeat until all three checks pass, then send or open the demo for the reviewer with the hand-off from [SKILL.md](../SKILL.md). Without a browser you can drive, hand the reviewer the demo and these checks as a list.

### 5. Capture the answer and prototype

Once the reviewer settles the question, record the verdict and preserve the demo as rule 5 of [SKILL.md](../SKILL.md) describes.
