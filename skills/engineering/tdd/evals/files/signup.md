# Signup evaluation input

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

`src/users.ts`:
```typescript
export async function registerUser(email: string) {
  return { email, registered: true };
}
```

`tests/users.test.ts`:
```typescript
import test from 'node:test';
import assert from 'node:assert/strict';
import { registerUser } from '../src/users.ts';
test('registration returns the user', async () => {
  assert.deepEqual(await registerUser('alice@example.test'), {
    email: 'alice@example.test', registered: true,
  });
});
```

The Postmark adapter contract is `sendEmail({ To, From, Subject, TextBody }): Promise<void>`. Welcome mail must be sent once to the registered address, from `welcome@example.test`, with subject `Welcome` and body `Thanks for joining.` Credentials and live Postmark access are unavailable in this environment.
