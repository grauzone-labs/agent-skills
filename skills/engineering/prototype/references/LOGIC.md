# Logic prototype

A single, self-contained HTML file — a **shareable demo** — that lets anyone drive a state model by clicking buttons. Use this when the question is about **business logic, state transitions, or data shape**: the kind of thing that looks reasonable on paper but only feels wrong once you push it through real cases.

Because it is one file with nothing to install, a designer, PM, or domain expert can evaluate the model directly. Write in their domain language, not the code's.

## When this is the right shape

- "I'm not sure if this state machine handles the edge case where X then Y."
- "Does this data model actually let me represent the case where..."
- "I want to feel out what the API should look like before writing it."
- Anything where someone wants to **press buttons and watch state change**.

For a question about appearance, return to [SKILL.md](../SKILL.md) and take its UI branch.

## Process

### 1. State the question

Write one visible paragraph at the top of the demo naming the state model and the question it answers. This is complete when a returning non-developer can tell what the demo is testing without reading its source.

### 2. Isolate the decision-rich logic

Put the logic answering the question in one small, pure `<script>` module. The page calls into it; the module never reaches into the DOM, button handlers, or `document`. This makes the state model easy to inspect, compare, and carry into the production implementation, where it is integrated and tested under the project's normal standards.

Choose the shape that fits the question:

- **A pure reducer** — `(state, action) => state` for discrete events over a single state value.
- **A state machine** — explicit states and transitions when legal actions are part of the question.
- **A small set of pure functions** over a plain data type for stateless transformations.
- **A class or module with a clear method surface** when the logic genuinely owns ongoing internal state.

This step is complete when the page can drive the model exclusively through that public surface.

### 3. Build the shareable HTML file

Use one plain HTML/CSS/JS file with every dependency inline. It must open directly from the filesystem, without a framework, bundler, or server.

Lay it out top to bottom:

1. **Title and one-line explanation** — the question from step 1.
2. **Current state and latest outcome** — render the full relevant state as labelled fields rather than raw JSON. After every attempt, show whether the action was accepted or rejected, the domain-language reason, and what changed.
3. **Free play** — show every action as a button so a reviewer can try any sequence. Dispatch each attempt through the model and render its outcome, including rejected or illegal transitions.
4. **Guided walkthroughs** — provide scenarios as tabs. Each tab states the situation and what to watch for, then presents its ordered actions as real buttons. Starting a walkthrough resets to a known initial state. Include the happy path, an awkward edge case, and an action that should be illegal when those cases apply.

Use restrained visual hierarchy: clean typography, generous spacing, and one accent colour. This step is complete when every action visibly produces an accepted or rejected outcome and every walkthrough starts from the same state.

### 4. Verify and hand it over

Open the HTML file directly from the filesystem. Complete every walkthrough and try every free-play action. Verify that the visible question, state, and latest outcome remain understandable without developer context. Then send or open the file for the reviewer.

### 5. Capture the answer and prototype

Once the prototype answers its question, record the verdict and preserve the executable file as [SKILL.md](../SKILL.md) describes. Carry the validated state-model decision—not the untested HTML implementation—into the production module.
