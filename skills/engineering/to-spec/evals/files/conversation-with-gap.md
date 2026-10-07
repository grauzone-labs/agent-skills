# Conversation so far

User: Support needs to be able to see the audit trail of a customer account: who changed what and when.

Agent: Account changes go through `AccountService.update`, which currently writes nothing but the new state. An audit trail needs an append-only record per change with the actor, the timestamp, the field, and the old and new values.

User: Yes, record those. Show them on the account page under a new "History" tab, newest first, for users with the `support` role only.

Agent: The record needs a retention rule: keep it forever, or trim it after some period? That changes the storage choice.

User: I have no idea yet; legal has not answered. Everything else is decided, write it up.

Agent: `account.service.test.ts` exercises `AccountService` through its public interface with an in-memory store, and `account-page.e2e.ts` covers the account page tabs.
