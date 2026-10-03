---
name: grilling
description: Grill the user relentlessly to settle a plan or decision. Use for a requested grill or when unresolved dependent decisions need a design tree.
license: MIT
metadata:
  author: "Sascha Grau"
  version: "1.0.0"
  category: "productivity"
---

# Grilling

Before the first question, read the user-provided plan and inspect the relevant repository context, domain documentation, and code. Build the initial **design tree** from that evidence: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are settled - the questions you can ask now without guessing at answers you have not heard. Ask the next frontier question, give your recommended answer, and wait for the user's response. Recompute the frontier after every answer.

Format each question like this:

```
❓ **Q1** - **<question title>**: <question body, including choices when useful>

➡️ <your recommended answer>
```

A settled decision pushes the frontier outward and can unblock dependent questions. A question whose answer depends on an open decision stays outside the frontier until that prerequisite is settled.

Finding facts is the agent's job. Gather a small, independent fact directly from the environment. For a substantial investigation that can proceed independently, dispatch a subagent and mark its dependent decisions as pending. Keep one user decision per round: after dispatching, wait for the current question's response before asking the next frontier question. The decisions are the user's: put each decision to them and wait.

When composed with the `domain-modeling` skill, challenge inconsistent or overloaded terms, cross-check claims against the code, and capture resolved terminology and qualifying ADR decisions inline. Capturing those decisions is not implementation: wait for the user's confirmation before implementing, publishing, or otherwise executing the resulting plan.

The session is done when the frontier is empty, every branch of the design tree has been visited, and nothing remains silently assumed. When the `domain-modeling` skill is active, the relevant domain documents reflect every settled term and qualifying decision. Wait for the user's confirmation of shared understanding before executing the resulting plan.
