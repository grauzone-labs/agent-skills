# Cache case: supplied repository snapshot

These are synthetic evaluation inputs, not results from a live repository.
The evaluation supplies this snapshot in place of repository access.

- Default branch: `main`; work branch: `cache-save`.
- Commit on the work branch: `Avoid writes for unchanged content`.
- No domain documents or tracker contract are present.
- `src/save.ts` is an internal helper.

Complete diff against `main`:

```diff
 export function save(content: string) {
+  if (content === cachedContent) return cachedResult;
   const result = write(content);
   cachedContent = content;
   cachedResult = result;
   return result;
 }
```

Supplied test evidence (the same regression test was run on both revisions):

```text
Command: npm test -- save.test.ts
Before (main): FAIL save skips unchanged content — expected write calls: 1; received: 2
After (cache-save): PASS save skips unchanged content
```
