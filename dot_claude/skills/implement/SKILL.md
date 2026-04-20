---
name: implement
description: Use when there is an approved plan ready to execute, or when the change is small enough that brainstorm/plan aren't warranted. Execute tightly — only change what the plan says, checkpoint at natural boundaries, surface out-of-scope findings rather than silently fixing them, run tests for modules touched. Enforce the reviewability contract (code → PR, non-code changes surfaced or prompted) and the isolation contract (autonomous/parallel work runs in a git worktree on its own branch). Hand off to the review skill when code works and tests pass.
---

# Implement

A plan exists (or the change is trivial enough to skip planning). Execute precisely. Implementation is where the brainstorm + plan investment pays off — the work should be *mechanical* if the earlier phases were done right. If it isn't mechanical, return to the earlier phase and fix the gap.

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

## Rules

1. **Scope discipline.** Only change what the plan says. If you discover something else needs changing, surface it — don't silently fix it.
   > "While implementing step 2, I noticed X — do you want me to include a fix, or track it separately?"

2. **Checkpoint at natural seams.** After each meaningful step (a file done, a module refactored, a feature wired up), pause with a one-line status. Don't wait until the end to surface problems.

3. **Test as you go.** For any module you touch, run the tests for that module before moving on. If tests didn't exist, note it — the `review` skill will address coverage gaps.

4. **No boy-scouting.** Don't refactor code "while you're there." Don't reformat files you're not editing. Don't delete "obviously unused" code — flag it to the user instead.

5. **Match CLAUDE.md conventions.** Preferred stack, tool choices, code style. Don't introduce new dependencies unless the plan called for them.

6. **Match existing repo conventions when present.** CLAUDE.md describes the user's greenfield preferences — existing repos get their own conventions. Match what's there.

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

## Handoff

Once code works and tests pass, hand off to the `review` skill. For autonomous flows, the `review` skill runs *before* the PR is opened — reviewed findings go into the PR description alongside the diff.
