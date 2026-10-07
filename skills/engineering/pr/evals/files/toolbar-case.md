# Toolbar case: supplied repository snapshot

Supply this snapshot together with `pr-body.md`. Repository access, application
execution, and test execution are unavailable in this evaluation. The snapshot
contains no captured screenshots or execution output.

- Default and target branch: `main`; work branch: `run-skill-button`.
- Commit: `Add Run Skill button and inline result card`.
- No domain documents or tracker contract are supplied.
- The changes use the existing skill picker and daemon API; no schema or public
  interface changes are included.

Complete component change in `apps/example/src/routes/session.tsx`:

```diff
 <SessionPage>
   useSessionEvents()
   <SessionToolbar>
+    <RunSkillButton />
   <SessionTimeline>
+    <SkillResultCard />
```

`RunSkillButton` and `SkillResultCard` come from `packages/ui`. The button opens
the existing skill picker and sends the selected skill to the daemon as an
expanded prompt. The card renders its result inline.

The supplied `package.json` defines `test:toolbar` as
`playwright test tests/session-toolbar.spec.ts`. Its `toolbar layout` scenario
captures the session toolbar and timeline screenshot. The reproduction command
on each revision is `npm run test:toolbar -- --grep 'toolbar layout'`.
