---
name: brainstorm
description: Use at the start of any non-trivial feature, project, or problem where the user has described a goal but not a fully-specified implementation. Exhaustively clarify scope, constraints, data shape, UX, edge cases, auth, deployment, testing, and success criteria through back-and-forth questions and surfaced concerns — keep going until every aspect of the approach is fully understood. The investment here lets later phases run autonomously. SKIP when the user is fixing a known bug, asking a narrow technical question, or requesting a trivial change.
---

# Brainstorm

The user is starting something new and the shape isn't settled. Your job right now is to **understand completely**. The explicit contract with this user: spend whatever time it takes in this phase so that the plan and implement phases can run with minimal interruption. Under-clarifying here is more costly than over-clarifying.

## Posture

- **Be exhaustive, not brief.** Ask until nothing material is ambiguous. It's better to ask a question the user finds obvious than to guess wrong and unwind later.
- **Raise concerns proactively.** If you foresee a risk, complication, or edge case, surface it now. "Have you thought about X?" is as important as "What do you want for Y?"
- **One batch at a time.** Ask related questions in a single message so the user can answer in a natural flow. Don't interrogate one-by-one.
- **Iterate.** After answers, identify what just got clarified and what's still open. Ask the next batch. Repeat.

## Dimensions to cover

Walk through every dimension that applies. Not every feature hits all of these — use judgment — but don't skip one that's ambiguous.

- **Outcome** — what does "done" look like? What does the user want to *do* with this that they can't today?
- **Users** — who uses this? Authenticated / anonymous? Admin vs regular? Solo tool or multi-user?
- **Data model** — what entities, relationships, constraints? What's the source of truth?
- **UX / flow** — what's the happy path click-by-click? Loading states, empty states, error states?
- **Edge cases** — what can go wrong? Duplicate submissions, race conditions, partial failures, offline, slow networks, rate limits?
- **Auth & permissions** — who can see what, do what? RLS policies if Supabase.
- **Integrations** — any third-party APIs, webhooks, email, payments? Rate limits, sandboxes, secrets?
- **Deployment & env** — where does this run? Local dev vs prod parity concerns? Env vars needed?
- **Testing** — what kind of testing does the user expect — unit, integration, e2e? Real DB or mocked?
- **Non-goals** — what should this *not* do, to prevent scope creep later?
- **Success criteria** — how will the user know it works? What's the acceptance test?
- **Constraints** — deadline, performance budget, cost, dependency limits, stack constraints from existing code.

## When to stop

Only stop when:

1. The user explicitly says they're satisfied with the clarification (e.g., "OK that covers it", "let's move on", "write the plan now").
2. You can accurately predict the user's answer to any further question you'd ask — nothing is load-bearing and still ambiguous.

If in doubt, ask one more question. Then hand off to the `plan` skill.

## Don't

- Don't propose files, architecture, or code in this phase. Those belong in `plan`.
- Don't batch-dump all 12 dimensions at once — that's overwhelming. Prioritize what's unclear *now*, get answers, then surface the next layer.
- Don't ask about things you can determine by reading the repo. Read first.
- Don't assume silence means agreement — if you floated an assumption and the user didn't push back, confirm it explicitly before relying on it.
