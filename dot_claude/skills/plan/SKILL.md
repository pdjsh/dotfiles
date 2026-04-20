---
name: plan
description: Use when the problem is understood (either after brainstorm is complete, or the user described it concretely enough) but implementation has not started. Produce a structured implementation plan — files to touch, sequence of changes, risks, explicit out-of-scope items, test plan — and request user approval before any code is written. SKIP when the change is a trivial one-liner or when the user has already approved a specific approach.
---

# Plan

The problem is understood. Now produce a plan the user can approve, redirect, or reject. The plan is the handoff from "understanding" (brainstorm) to "execution" (implement).

## Shape of a good plan

1. **Goal** — one sentence restating what we're building.
2. **Approach** — the strategy, named at a high level (e.g., "add a middleware that X", not pseudocode).
3. **Steps** — ordered. Each step names the file(s) touched and what specifically changes. Group related edits into one step; don't fragment.
4. **Data / schema changes** — if any. Migration file, type regen, RLS policy updates.
5. **Risks / unknowns** — what could go wrong, what you're unsure about. Be honest about thin spots.
6. **Out of scope** — things explicitly NOT in this change. Write these down so scope creep is visible.
7. **Test plan** — how the user will verify this works. Commands to run, UI flows to try, edge cases to check.

## Rules

- **Read the repo first.** Every file named must be a real file you've located, not a guess. If a file will be newly created, say so explicitly.
- **Keep it under ~40 lines.** If the plan is longer, it's too big — break into milestones and get approval on scope before expanding.
- **Flag the one load-bearing risk.** If something might break in a non-obvious way, put it under Risks, not buried in a step.
- **Name concrete files, concrete commands.** "Update config" is vague. `supabase/migrations/20260420_add_foo.sql` is concrete.
- **Respect CLAUDE.md conventions.** Don't propose npm if the repo uses pnpm. Don't propose a new dep if an existing one works.

## Ask for approval

End the plan with an explicit ask. Examples:

> OK to proceed with this plan?
> Want me to adjust anything before I start?
> If this looks right, I'll move to implement.

Don't assume the user has approved just because they replied — look for a clear go-ahead.

## After approval

Hand off to the `implement` skill. If the user pushes back on the plan, revise and re-present rather than partially adopting feedback.

## Edge cases

- **User replies "just do it"** without reviewing — still show the plan, they may skim. Don't skip.
- **Plan reveals brainstorm missed something** — return to brainstorm for that piece, then re-plan.
- **Two viable approaches** — present both briefly with tradeoffs, ask which one. Don't pick for them.
