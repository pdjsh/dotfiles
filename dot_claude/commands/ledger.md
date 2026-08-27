---
description: Show the task board — this run, or every run across every repo. Optionally act on it (add, start, done, block, drop).
argument-hint: "[list | show | add \"task\" | start N | done N \"evidence\" | block N \"why\"]"
---

Invoke the `ledger` skill.

With no arguments: run `ledger show` for the run bound to this directory, then
`ledger list` for everything else in flight. Report it in **one screen**:

- what is done (one line each, with the evidence recorded against it)
- what is in progress right now, and for how long
- what is blocked, and on what
- what is left, in order
- anything surfaced but not fixed

Then, if `ledger doctor` reports anything, say what needs fixing in the breakdown
— tasks too coarse to check, split focus, a task that has gone quiet, a ledger
that is finished but unwrapped.

With arguments: `$ARGUMENTS` is a ledger subcommand — run it, then show the
updated board.

If no ledger is bound to this directory and there is work in flight, offer to
create one and backfill it from what has already happened this session.
