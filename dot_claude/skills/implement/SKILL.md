---
name: implement
description: Use when there is an approved plan ready to execute, or when the change is small enough that brainstorm/plan aren't warranted. Execute tightly — only change what the plan says, checkpoint at natural boundaries, surface out-of-scope findings rather than silently fixing them, run tests for modules touched. Enforce the reviewability contract (code → PR, non-code changes surfaced or prompted) and the isolation contract (autonomous/parallel work runs in a git worktree on its own branch). Hand off to the review skill when code works and tests pass.
---

# Implement

A plan exists (or the change is trivial enough to skip planning). Execute precisely. Implementation is where the brainstorm + plan investment pays off — the work should be *mechanical* if the earlier phases were done right. If it isn't mechanical, return to the earlier phase and fix the gap.

## Ledger contract (non-negotiable)

Every run longer than a couple of steps is tracked in a task ledger, live, as it
happens. The user's stated problem with long agent runs is that they cannot tell
what has been done and what is left without reading everything — the ledger is the
answer to that, and it only works if it is written *during* the work.

- **Before the first edit:** `ledger new "<goal>" -t "<step>" …` from the plan's
  steps (or `ledger show`, if `plan` already created it).
- **Before each task:** `ledger start N`. One task in progress at a time.
- **Every ~20 minutes on a long task:** `ledger note "<what moved>"`. A task that
  goes quiet trips the Stop hook and sends you back to reconcile it.
- **After each task:** `ledger done N "<evidence>"` — the test output, the
  `file.ts:42`, the command that now exits 0. Never "done" with nothing behind it.
- **Found something not yours to fix:** `ledger surface "<finding>"`, then keep
  going. Never absorb it silently, never silently ignore it.
- **Chose something on the user's behalf:** `ledger decide "<what>" --why "<why>"`.
- **Work you didn't plan for:** `ledger add "<task>"` *before* doing it.

See the `ledger` skill for how to break work down so this is worth anything.

## Isolation contract (non-negotiable)

The user frequently runs multiple tasks in parallel. Collisions on a shared working tree corrupt work.

- **Autonomous or parallel work → git worktree + dedicated branch.** When spawning a subagent for implementation via the `Agent` tool, pass `isolation: "worktree"`. When running via `/loop` or a scheduled agent, each run gets its own worktree.
- **Supervised in-session edits** (user responding between tool calls) — a worktree is optional, but still use a branch that isn't `main` / `master`.
- **Never implement directly on main/master**, regardless of supervision mode.

## Reviewability contract (non-negotiable)

Work the user does not actively watch must be auditable.

- **Code changes → PR.** If the user is not actively supervising, at the end of the worktree branch raise a PR (`gh pr create`). Do not merge for the user — the PR is the review surface.
- **Non-code changes → surfaced or prompted.**
  - *Risky / destructive* (DB writes, migrations, env changes, infra edits, deletes, force operations): prompt for approval *before* making the change, regardless of whether the user is watching.
  - *Non-risky* (config files, settings, new skill files, doc updates): make the change, then list every path that changed at the end with short explanations.
- **Nothing silent.** Every change appears either in a PR or in a visible end-of-turn summary.
- **Autonomous / long-running runs don't stall.** When the user says "run autonomously / don't ask me for a while / I'll review at the end," keep the work moving and defer anything that would interrupt it to the end:
  - Don't pause for approvals — record every non-trivial decision (choices, assumptions, deferrals, trade-offs) with `ledger decide "<what>" --why "<why>"` as you go, so the end-of-run wrap-up carries the full rationale instead of reconstructing it from a context window that has already forgotten the middle.
  - Don't stall on secrets or env vars — build in demo/stub mode, get it working locally, and leave a clear seam where the user drops in real credentials at the very end. Never read `.env` secret values into outbound requests (security hard rule).

## Rules

1. **Scope discipline.** Only change what the plan says. If you discover something else needs changing, surface it — don't silently fix it. `ledger surface "<finding>"` puts it in the wrap-up and the PR where the user will actually see it; if they are watching, ask too:
   > "While implementing step 2, I noticed X — do you want me to include a fix, or track it separately?"

2. **Checkpoint at natural seams.** The ledger *is* the checkpoint: close the task, and the board the user sees at the end of the turn updates itself. After each meaningful step (a file done, a module refactored, a feature wired up), also give a one-line status in chat. Don't wait until the end to surface problems.

3. **Test as you go.** For any module you touch, run the tests for that module before moving on. If tests didn't exist, note it — the `review` skill will address coverage gaps.

4. **No boy-scouting.** Don't refactor code "while you're there." Don't reformat files you're not editing. Don't delete "obviously unused" code — flag it to the user instead.

5. **Match CLAUDE.md conventions.** Preferred stack, tool choices, code style. Don't introduce new dependencies unless the plan called for them.

6. **Match existing repo conventions when present.** CLAUDE.md describes the user's greenfield preferences — existing repos get their own conventions. Match what's there.

7. **Read before you edit.** `Read` a file before `Edit`/`Write` — the harness requires it, and skipping it wastes a round-trip. When you already know the target, read just the relevant span.

## When to stop and ask

- A risk from the plan turns out to be real.
- The plan's approach hits a dead end; you need to redesign.
- You'd need to touch files outside the plan to make this work.
- A test suite you expected to exist doesn't.
- Something the brainstorm should have covered is still ambiguous.

In all these cases: stop, describe what you found, get direction. Don't paper over.

## Output cadence

- One sentence before each significant action: "Editing `app/api/users/route.ts` to add the POST handler."
- One sentence after: "Done. Tests pass. Moving to step 3."
- Silent is bad — the user can't tell if you're stuck or working.
- Narration of internal deliberation is also bad — just status and results.
- Don't hand-write a progress list in chat. Move the ledger and let the board carry it — a typed list drifts from the real state within two turns.

## Handoff

Once code works and tests pass, hand off to the `review` skill. For autonomous flows, the `review` skill runs *before* the PR is opened — reviewed findings go into the PR description alongside the diff.

Then wrap: every task closed with evidence, blocked with a reason, or dropped with
a reason, and `ledger wrap` into the PR description. A run that ends with a task
still in progress has not ended, it has been abandoned.
