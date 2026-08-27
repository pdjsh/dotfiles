---
name: ledger
description: Use whenever work will take more than a few minutes or more than a couple of steps — before starting it, throughout it, and at the end of it. Maintains a persistent, human-readable task ledger in ~/.claude/ledgers so the user can see at any moment what is done, what is in progress, what is blocked, and what is left, without reading back through tool calls. Also use when the user asks "what are you doing", "where are we", "what's left", "show me the todos", or when a session resumes and needs to re-anchor on a run already in progress.
---

# Ledger

## The problem this exists to fix

A long agent run produces a wall of tool calls and one summary at the end. Halfway
through, the user cannot answer three basic questions — *what is already done*,
*what is happening right now*, *what is left* — without scrolling through
everything. Work gets silently dropped, silently expanded, and re-done after a
compaction. The summary at the end is written from a context window that has
already forgotten the middle.

The ledger is the fix. **It is the record, not the recap.** It is written *as the
work happens*, it survives compaction and restarts, and it lives in a file the
user can open, grep and edit while you are still working.

## The one rule

> Nothing happens that is not on the ledger.

If you are about to do something that is not on the list, add it to the list
first — even if adding it takes longer than the work. That is not overhead, that
is the entire point: the list is what makes a two-hour run legible in ten seconds.

## 1. Start a ledger

Open one whenever the work is more than a couple of steps: anything with an
approved plan, anything autonomous, anything that will outlive a single turn.
Trivial one-liners do not need one.

```sh
ledger new "Add custodial rating profiles to the nav" \
  -t "Add the profile schema + RLS in one migration" \
  -t "Regenerate types and fix the 3 call sites" \
  -t "Render profiles in the nav behind a feature flag" \
  -t "Add a test for the empty-profile case" \
  -t "Review pass + open the PR"
```

The ledger binds to the current git worktree, so parallel agents in parallel
worktrees each get their own and never collide. Coming from the `plan` skill, the
plan's steps *are* the tasks — create the ledger as the last act of planning.

## 2. Break the work down properly

This is the part that decides whether any of the rest works. A ledger of five
vague tasks is worse than no ledger, because it looks like tracking.

**Every task is a verb, an object, and an end state you could check.**

| Don't write | Why it fails | Write instead |
|---|---|---|
| `Refactor the API layer` | no end state — it is never done | `Extract fetchWithRetry from api/client.ts and repoint the 4 call sites` |
| `Fix bugs` | unbounded; hides how many there are | one task per bug, each naming the bug |
| `Tests` | cannot be checked item by item | `Add a test for the 429-retry path in client.test.ts` |
| `Handle auth` | a topic, not a task | `Add an RLS policy so a user reads only their own orders` |
| `Investigate why sync is slow` | fine — but it must end in a recorded finding, not a feeling |

Size each task to **one sitting** — roughly half an hour of agent work, rarely
more than three files. If you cannot say what would prove it done, it is two
tasks. If it needs a paragraph to describe, it is a milestone: split it, or use
subtasks (`ledger add "…" -p 3`).

Order by what unblocks what. **The first task is the one that proves the approach**
— the risky bit, the unknown API, the migration that either applies or doesn't —
not the easy scaffolding. **The last task is always verification**: tests, review,
PR. Never "cleanup".

Keep it to **12 top-level tasks or fewer**. Past that it is a project, and it
wants milestones or a second ledger.

## 3. Work the ledger

```sh
ledger start 3                                  # before you touch anything
ledger note "migration applies; types regenerated"   # every ~20 min on a long task
ledger done 3 "supabase/migrations/20260827_profiles.sql; 14 tests pass"
```

- **One task in progress at a time.** Split focus is how work gets lost. If you
  genuinely must park one, `ledger block 3 "waiting on the API key"` — with the
  reason, always.
- **Heartbeat every ~20 minutes.** A task that sits in progress with nothing
  recorded against it trips the Stop hook and sends you back to reconcile it.
  Treat that as the design working, not as an interruption.
- **Evidence is mandatory on `done`.** Write the thing that would convince a
  skeptic who does not trust you: the test output, the `file.ts:42`, the command
  that now exits 0. "Done" with no evidence is a claim, not a result.
- **Surface, never absorb.** Something broken that is not yours to fix today:
  `ledger surface "auth/session.ts leaks the refresh token into logs"`. It lands
  in the wrap-up and the PR instead of quietly becoming your problem or quietly
  disappearing.
- **Record decisions where they happen.** Anything you chose on the user's behalf:
  `ledger decide "central ledger store" --why "cross-agent visibility is the point"`.
  On an autonomous run this *is* the decision log the user has asked for.
- **Discovered work gets added.** `ledger add "…"` mid-run is normal and healthy;
  the growth of the list is real information about the shape of the job.

## 4. Wrap up properly

Wrapping up is a step of the work, not a flourish at the end of it. Run it when
the last task closes — and when the user says "stop", "that's enough", or the run
is being handed back for any other reason.

```sh
ledger wrap
```

It composes the five things a handoff has to answer, from what actually happened
rather than from memory:

1. **What shipped** — each done task with its evidence.
2. **What is still open** — in progress, blocked (with the reason), not started.
3. **What was deliberately skipped** — dropped tasks with why. This is the one
   most often lost, and the one that most often bites.
4. **What was decided, and why.**
5. **What was surfaced and not fixed.**

Put that block in the PR description. Give the user the short version in chat and
the ledger path. Then say the single next action.

Never wrap with a task still in progress: close it, block it, or drop it first.
Every one of those three is an honest answer; leaving it open is not.

## 5. Several agents at once

Each pane, worktree and repo carries its own ledger, bound by directory. To see
every run at once — which is the view the user actually wants at the end of a day:

```sh
ledger list
```

When you spawn a subagent for a slice of the work, that slice is a task (or a
subtask) on *your* ledger. Close it with the subagent's result as the evidence.
Do not let a subagent's work exist only inside its own transcript.

## Command reference

| Command | What it does |
|---|---|
| `ledger new "<goal>" -t "…" -t "…"` | start a ledger, bound to this worktree |
| `ledger add "<task>" [-p N]` | add a task, or a subtask of N |
| `ledger start N` / `done N "<evidence>"` | move a task; evidence required on done |
| `ledger block N "<why>"` / `unblock N` | park a task, with the reason |
| `ledger drop N "<why>"` | deliberately not doing it — recorded, not deleted |
| `ledger rm N` | delete a task outright: a typo, not a decision |
| `ledger note "<progress>" [-n N]` | heartbeat on the current task |
| `ledger decide "<what>" --why "<why>"` | decision log entry |
| `ledger surface "<finding>"` | found it, not fixing it, not losing it |
| `ledger link <url> --label PR` | attach the PR / issue |
| `ledger show` / `board` / `status` | full view / compact board / one line |
| `ledger list [-a]` | every run, across every repo |
| `ledger doctor` | breakdown and hygiene checks |
| `ledger wrap` | the wrap-up block; closes the ledger |
| `ledger path` | the file, for reading or hand-editing |

Ledgers live in `~/.claude/ledgers/*.md`. They are plain markdown — the user may
edit them by hand mid-run, and your next command must not clobber that. Re-read
before large rewrites.

## Edge cases

- **The user edited the ledger while you worked.** Their edit wins. Re-read it
  (`ledger show`) before continuing.
- **A resumed or compacted session.** The SessionStart hook re-injects the board.
  Trust the ledger over your recollection of the conversation.
- **The plan changed mid-run.** Drop the tasks that no longer apply with a reason,
  add the new ones. Do not rewrite history to look tidy — the diff between the
  original list and the final one is genuinely useful to the user.
- **Work with no ledger that has already grown long.** Create one now and backfill
  the done tasks with what you actually did. Late is much better than never.
- **The user asks "where are we".** `ledger show` and answer from it, in one
  screen. Do not narrate the transcript.
