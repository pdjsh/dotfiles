---
description: Close out the current run — produce the wrap-up (shipped, open, skipped, decided, surfaced) and the single next action.
---

Invoke the `ledger` skill and run its wrap-up ritual.

1. Reconcile first. Every task must be `done` (with evidence), `blocked` (with a
   reason), or `dropped` (with a reason). Nothing may be left in progress. If a
   task is genuinely half-finished, split it: close the part that is done, and add
   the remainder as a new task.
2. Run `ledger wrap`.
3. Put that block in the PR description if there is a PR; `ledger link <url> --label PR`.
4. Give the user, in chat, the short form:
   - what shipped, and what proves it
   - what is verified versus what is assumed
   - what was deliberately skipped, and why
   - what is still open
   - **the single next action**
5. Print the ledger path so they can read the full record.

Do not pad this. If something did not get done, say so plainly — an honest short
wrap-up is the whole value of the ritual.
