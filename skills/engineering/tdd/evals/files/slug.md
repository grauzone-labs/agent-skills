# Slug evaluation input

Use a fresh temporary project for this case with Node.js 22.18 or later. No packages or network access are required. Create the files below before starting the evaluated task. Run the baseline with `node --test tests/*.test.ts`; it must pass. New tests use `node:test` and `node:assert/strict`.

`package.json`:
```json
{"type":"module","scripts":{"test":"node --test tests/*.test.ts"}}
```

`tests/baseline.test.ts`:
```typescript
import test from 'node:test';
import assert from 'node:assert/strict';
test('runner works', () => assert.equal(1, 1));
```

`src/slug.ts`:
```typescript
export function slugify(title: string): string { return title; }
```

Requirements are limited to ASCII letters, spaces, and hyphens. Convert letters to lowercase, replace each run of spaces with one hyphen, and strip leading/trailing hyphens. Representative independent cases are `Hello` → `hello`, `hello  world` → `hello-world`, and `--hello--` → `hello`.
