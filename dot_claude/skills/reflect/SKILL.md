---
name: reflect
description: Use when the user invokes /reflect, or at the start of a session where notable feedback/corrections have accumulated since the last reflection. Reviews recent conversation transcripts, auto-memory entries, global CLAUDE.md, user skills, and settings.json, then proposes specific config changes (never auto-applies). Outputs a diff-style proposal the user accepts, edits, or rejects item-by-item.
---

# Reflect

Goal: turn accumulated in-session feedback into durable config improvements. You review; you propose; the user decides. **Never edit any config file from this skill directly — you only produce a proposal.** Edits happen after the user approves each item.

## Inputs to examine

Walk these before proposing anything:

1. **Recent conversation transcripts** — `~/.claude/projects/` subdirectories contain session logs. Look for:
   - Patterns of correction (user said "don't do X" multiple times)
   - Patterns of friction (same permission prompt repeated, same skill failing to trigger)
   - Surprising approvals (user liked an unusual approach — worth preserving)
2. **Auto-memory entries** — `~/.claude/projects/*/memory/`. Read every file.
   - Which feedback has fired repeatedly? That's a candidate for promotion.
   - Which memory is stale, contradicted by newer feedback, or duplicated?
3. **Global CLAUDE.md** — `~/.claude/CLAUDE.md`.
   - Does it miss something that came up repeatedly?
   - Is anything in it wrong, stale, or superseded?
4. **Skills** — `~/.claude/skills/*/SKILL.md`.
   - Did any skill fail to trigger when it should have? → Tighten trigger description.
   - Did one fire when it shouldn't? → Narrow trigger description.
   - Is any skill's body outdated, contradicted by new feedback, or missing a section?
5. **Settings.json** — `~/.claude/settings.json`.
   - Did any permission prompt fire multiple times for the same command pattern? → Candidate for `allow`.
   - Did auto mode approve something that should have gated? → Candidate for `ask` or `deny`, or tune `autoMode.soft_deny`.
6. **Commands** — `~/.claude/commands/*.md`. Same lens as skills.
7. **Hooks** — any broken? Any that fire too often / not often enough?

## Proposal categories

For each finding, propose exactly one of:

- **CLAUDE.md edit** — add, remove, or clarify a standing instruction.
- **Skill edit** — tighten/loosen trigger description, edit content, split a skill, or retire one.
- **New skill** — a recurring pattern not yet covered.
- **Settings change** — add to `allow` / `ask` / `deny`, adjust `autoMode.soft_deny` or `autoMode.allow`.
- **Memory promotion** — a feedback memory that's fired often → merge into CLAUDE.md or a skill.
- **Memory retirement** — stale, contradicted, or now redundant memory.
- **Hook change** — add, remove, or adjust a hook.

## Output format

Produce a single message with a numbered list. Each item has a header, a "why" (with evidence — how many times, when), a diff or concrete change, and an explicit approval ask.

```
# Reflection — YYYY-MM-DD

Scanned: N recent sessions (date range), M memory entries, K skills.

## Proposals

### 1. [CLAUDE.md] Add under "Conventions": "Prefer pnpm over npm for any new repo."
**Why:** User corrected this 3 times between 2026-04-12 and 2026-04-18.
**Diff:** (shown)
**Apply?** y / n / edit

### 2. [Skill: plan] Narrow trigger to exclude bug fixes.
**Why:** Fired on a one-line typo fix 2026-03-12; user said "skip the plan, just do it."
**Diff:**
```diff
- description: Use when the problem is understood...
+ description: Use when the problem is understood... SKIP for bug fixes and one-line changes.
```
**Apply?** y / n / edit

### 3. [Settings] Add `Bash(uv sync*)` to allow list.
**Why:** Prompted 5 times in session on 2026-04-19.
**Apply?** y / n / edit

### 4. [Memory retire] `feedback_pnpm_preference.md`
**Why:** Now covered by CLAUDE.md after proposal #1.
**Apply?** y / n / edit
```

Walk through the list with the user. Apply only what they approve, one at a time. After each approval, make the change and confirm what changed and where before moving to the next.

## Rules

- **Don't propose from a single incident** unless it was costly or high-risk.
- **Don't rewrite memories without asking.**
- **Don't invent patterns.** If the data is thin: "Only 2 sessions since last reflection — not much to propose."
- **Always show evidence.** "Why" must cite concrete instances (dates, session context, count).
- **Keep the proposal scannable.** If it's longer than 10 items, group by category or triage the least-important to a "deferred" section.
- **Never auto-apply**, even for seemingly trivial changes. The user's trust depends on explicit consent.

## After the session

If the user approves changes, make them, and optionally update this skill itself if the reflection process itself could be improved.
