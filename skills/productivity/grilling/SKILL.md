---
name: grilling
description: Grills the user relentlessly to settle a plan or decision. Use when the user asks for a grill or when unresolved dependent decisions need a design tree.
compatibility: Dispatching a substantial investigation needs a host with a subagent dispatch tool; without one, the agent investigates in the session.
license: MIT
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "productivity"
---

# Grilling

Before the first question, read the user's plan or decision and inspect the relevant repository context, domain documentation, and code. Build the initial **design tree** from that evidence: every decision branches into the decisions that hang off it. The tree is built when every decision carries its prerequisite decisions and facts and an open or settled status.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisite decisions are settled and prerequisite facts returned. Each round, ask the one frontier question with the most decisions hanging off it, give your recommended answer, and wait for the user's answer. Recompute the frontier after every answer and every returned fact; a changed answer reopens the decisions that hang off it.

Format each question like this, numbering questions consecutively through the session:

```
❓ **Q<n>** - **<question title>**: <question body, including choices when useful>

➡️ <your recommended answer>
```

Facts are the agent's job; decisions are the user's, including the ones you could settle yourself. Dispatch a substantial investigation that can proceed independently to a subagent, and still put the round's question to the user while it runs. When investigation cannot establish a required fact because the evidence is outside the repository, ask the user for its source; the decisions that depend on it stay open while the independent branches continue.

When composed with the `domain-modeling` skill, capture each settled term, cross-context relationship, and qualifying decision through it in the round it lands.

When the frontier is empty and every branch of the design tree has been visited, present the settled design tree in this form and ask the user to confirm it:

```markdown
## Settled design

- <decision>: <answer>
  - <dependent decision>: <answer>
```

**Complete when:** every decision in the design tree carries the user's answer, the domain documents reflect every settled term, cross-context relationship, and qualifying decision when the `domain-modeling` skill is active, and the user has confirmed the settled design; implementing, publishing, or otherwise executing the plan starts only after that confirmation.
