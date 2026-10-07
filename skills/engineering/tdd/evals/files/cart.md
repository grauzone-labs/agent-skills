# Cart evaluation input

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

The cart module does not yet exist. Prices and totals use integer cents. Add an item with an ID and unit price; remove by ID; apply one percentage coupon to the subtotal; then apply tax to the discounted subtotal and round once to the nearest cent. A 1000-cent item with a 10% coupon and 20% tax totals 1080 cents. No persistence or external service is involved.
