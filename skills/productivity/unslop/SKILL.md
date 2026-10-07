---
name: unslop
description: Cuts AI tells from any writing. Use when the user says slop or unslop, or wants prose, documentation, or messages edited or reviewed for anything that sounds like AI.
compatibility: Requires bash, grep, and sed for scripts/scan.sh.
license: MIT
disable-model-invocation: true
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "productivity"
---

# Unslop

## Process

Keep every fact, number, name, command, code span, URL, and defined domain term, and keep the author's register (a casual message stays casual, a spec stays terse). Name only sources, actors, mechanisms, and measurements the text supplies. These constraints beat a rule's replacement: `--features` stays in a command, and "vector" stays where the text defines it as a mathematical term.

1. **Find the tells.** When the text is a file, execute this skill's `scripts/scan.sh <file>`; it prints candidate hits for the rules its header lists. If it exits 2, note `Scan unavailable: <error>.` for the final reply. Then read the whole text once against every rule, the scanned ones included (the regexes are partial and flag some literal uses), and judge each hit in context. Pasted text gets only the reading pass. Done when every rule and every hit has been checked against the whole text.
2. **Report or rewrite.** Review only (the user asked for a review or said not to change the text): leave the text unchanged and reply with one line per confirmed tell, `<line>: rule <n>: "<quoted phrase>"`, counting pasted lines from 1 and prefixing `<file>:` when more than one file was reviewed; with no tells, reply `No tells found.` Stop after the report; it is the whole reply, with no explanation, change list, or summary before or after it. Otherwise fix every confirmed tell: edit a file in place, or rewrite pasted text. Done when every confirmed tell has a fix that keeps the constraints above.
3. **Re-check and deliver.** Repeat step 1 on the result and compare it with the original for lost facts. A fix that introduced a new tell (an em dash swapped for a colon, a split sentence left as a fragment) or dropped a fact goes back to step 2. Done when a pass finds nothing. Then deliver exactly one reply, with no explanation, change list, or summary before or after it: for pasted text, the rewritten text alone; for a file, reply `Updated <file>. Re-check: no tells found.` or `Unchanged <file>. Re-check: no tells found.`, plus the scan note if there was one.

## Rules

Rule numbers are stable ids cited by other documents; a gap is a removed rule.

### Content

3. **Superficial -ing phrases.** "highlighting...", "ensuring...", "reflecting...", "showcasing...", "fostering...". Delete or expand with real sources.
5. **Vague attributions.** "Experts believe", "Industry reports suggest", "Some critics argue". Name the source or delete.

### Language

7. **AI vocabulary.** Additionally, crucial, delve, enduring, enhance, fostering, garner, interplay, intricate, landscape (abstract), pivotal, showcase, tapestry (abstract), testament, underscore, vibrant. Replace with plain words.
8. **Fancy ways to say "is".** "serves as", "stands as", "boasts", "features". Just say "is" or "has".
9. **"Not just X, but Y."** State the point directly instead.
10. **Rule of three.** Forcing ideas into groups of three. Use the natural number.
11. **Synonym cycling.** Protagonist, main character, central figure, hero all in one paragraph. Pick one, repeat it.
12. **False ranges.** "from X to Y" where X and Y aren't on a meaningful scale. List topics directly.

### Style

13. **Em dash overuse.** Replace every em dash with a period or a comma; an en dash, a spaced hyphen, or parentheses standing in for a dash get the same replacement.
14. **Colon overuse.** A colon introduces a list or an example. A colon used as a mid-sentence connector ("If you're coming from traditional automation: instead of registering event handlers, you describe conditions") gets rewritten so the point stands on its own: "Describing when the scheduler should fire works best as plain English."
15. **Boldface overuse.** Reserve bold for the one item the reader must find; proper nouns and acronyms stay plain.
16. **Inline-header lists.** The tell is a bold label and colon that restates the line: "**Performance:** Performance improved...". Merge those bullets into one sentence or paragraph with no list markers left. A bold lead-in that ends in a period, names the item, and is followed by genuinely new detail ("**Schema in TypeScript.** Tables live in one file.") is fine, not a tell.
17. **Title case headings.** Use sentence case.
18. **Decorative emojis.** Remove from headings and bullets.
19. **Curly quotes.** Replace with straight quotes.

### Communication artifacts

20. **Chatbot phrases.** "I hope this helps!", "Let me know if...", "Of course!", "Certainly!", "Found the smoking gun!" Remove.
22. **Sycophantic tone.** "Great question! You're absolutely right!" Respond directly.

### Filler

23. **Filler phrases.** "In order to" becomes "To". "Due to the fact that" becomes "Because". "It is important to note that" gets deleted.
24. **Excessive hedging.** "could potentially possibly be argued that it might" becomes "may".
25. **Generic conclusions.** "The future looks bright." State specific plans or facts.

### Jargon

26. **Abstract metaphor nouns.** Substrate, wedge, vector, locus, vantage, nexus, primitive (as noun), harness (as metaphor), surface (as in "API surface"), bedrock, scaffolding (as metaphor), modality, paradigm, gold-plating, ratchet (as metaphor), evacuate (for moving code), endgame, north star, flywheel. "Substrate" becomes "base". "Wedge in" becomes "add". "Vector" becomes "way" or "method". "Gold-plating" becomes "more than the job needs". "Ratchet" becomes the mechanism's real name or "a limit that only tightens". "Evacuate" becomes "move out". "Endgame" becomes "the last phase". Pick the concrete word.

### Plain speech

27. **Say what it does, not how it feels.** "the database stays close at hand", "SQL you can read", "types that follow your schema" name a feeling. The fix names the mechanism or a number: "`.toSQL()` returns the exact string sent to the database", "a column rename fails the build". Ask what the sentence tells the reader to do or know, then write that. If you can't restate it as a concrete instruction, fact, or number, cut it. One more check: a sentence that could appear unchanged in another project's docs and carries no instruction, fact, or number says nothing about this one. Cut it.
28. **Shorten or split dense sentences.** If the reader has to backtrack to parse a sentence, break it in two or drop clauses. One idea per sentence.
29. **Active voice.** Catch "is/are/was/were + past participle" and name the actor the text supplies: "the file is parsed by the loader" becomes "the loader parses the file". A passive whose actor the text does not name stays as written and is not reported.
30. **Cut adverbs, or use a stronger verb.** "runs quickly" becomes "is fast" or the number. "significantly improves" becomes the measured delta. An adverb that carries a fact ("automatically", "twice") stays.
31. **Prefer the plain word.** "utilize" becomes "use", "leverage" becomes "use", "facilitate" becomes "help", "numerous" becomes "many", "in the event that" becomes "if".
32. **Mannered prose.** Metaphor or flourish where a literal phrase exists: aphorisms ("wire it or delete it"), rhetorical fragments for effect, personified code ("the plan holds it"), figurative verbs ("rides along", "stands on"), stock framing phrases. "A dial worth turning" becomes "a parameter worth varying". Rule 26 covers the metaphor nouns.
33. **Over-compression.** Dropped articles, verbless fragments, symbol-speak, and abbreviations that make the reader decode instead of read. "Parser rejects bad date → exit 2, no write" becomes "The parser rejects a bad date, exits with code 2, and writes nothing." Write whole sentences with their articles and verbs, and spell out arrows and abbreviations.
