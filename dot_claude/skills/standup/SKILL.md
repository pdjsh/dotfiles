---
name: standup
description: Use at the start of a working day, when the user invokes /standup, or when they ask "what did I do yesterday", "catch me up", "what's on my plate", "where did I leave off". Runs the daybook collector (git, pull requests, Claude Code sessions, herdr agents), layers in Linear and calendar, then produces a ranked briefing that ends in a numbered pick-list of next actions. It is a briefing, not a work session — it never starts the work itself.
---

# Standup

The first thing that runs in a working day. It answers three questions in order —
*what happened since I last worked*, *what is waiting on me*, and *what should I
do first* — and then hands off to whichever workflow skill the chosen item needs.

It is a **read**. Do not commit, push, merge, close, comment, or resume anything
while producing it. The briefing ends with a pick-list; the user picks; only then
does work start.

## 1. Collect

Run the collector first, before anything else, and before saying a word to the
user. It is one command and it gathers four sources that would otherwise be
twenty tool calls:

```sh
daybook-collect --max-age 300
```

If `daybook-collect` is not on `PATH`, try these in order and use the first that
exists:

```sh
python3 ~/Projects/herdr-plugins/tools/daybook/daybook-collect.py --max-age 300
python3 ~/Projects/herdr-plugins/.worktrees/daybook/tools/daybook/daybook-collect.py --max-age 300
```

If none of them exists, say so in one line, then build the briefing from
`git`/`gh`/transcripts directly — degraded is fine, silent is not.

What comes back is one JSON document: `window`, `totals`, `repos` (each with its
`checkouts`), `prs` (`mine`, `review_requested`, `merged_in_window`), `sessions`,
`agents`, `attention`, `errors`. Read it; **never paste it at the user**.

`attention` is the pre-ranked open-loop list and the spine of the briefing.
Severity `1` is blocked, `2` is waiting on the user, `3` is a loose end, `4` is
housekeeping. Trust the ranking — it is the same one the `daybook` herdr pane
uses, and the two should agree.

`window.label` says what "yesterday" actually means. On a Monday it is Friday;
after a week off it is a week. Lead with it so the user knows the frame.

## 2. Layer in what the collector cannot see

The collector only reads the local machine and GitHub. Add, when available:

- **Linear** — the "what am I supposed to be doing" axis that git and PRs cannot
  supply. `list_issues` with `assignee: "me"` returns completed issues mixed in,
  so filter to `statusType` of `started`, `unstarted`, or `triage` — never present
  a `Done` issue as an open loop. Ask for `fields: ["title","status","statusType",
  "priority","team","url"]`; the default response is wider than a briefing needs.

  **Then correlate it.** A Linear issue, a running agent, a feature branch and an
  open PR are frequently the same piece of work under four names — an agent whose
  pane title paraphrases an issue, sitting in a worktree whose branch slug
  paraphrases it again, with a PR whose title paraphrases it a third time. Match
  them on the words they share and say it once, rather than listing the same work
  four times in four sections. That correlation is the single most useful thing
  this skill does that neither the collector nor Linear can do alone.
- **Calendar** — today's meetings, so "today's three" does not assume eight free
  hours. Only if the calendar MCP is already authenticated: **never start an
  authentication flow during a standup.**

Any source that is missing or unauthenticated gets one line under **Notes** and
nothing more. A briefing that stalls asking permission to read a calendar has
failed at its one job.

## 3. Synthesise

Fixed shape, in this order. Skip a section entirely rather than printing it empty.

**Since \<window label\>** — what actually happened. Commits grouped by
repository with the shape of the work, not a changelog; PRs merged; sessions that
ran and what they were about. Three to six lines. The user was there — this is a
reminder, not a report.

**Needs you now** — severity 1 and 2, verbatim in intent but tightened in
wording. Each line ends in the concrete next move (the collector's `hint` is
usually it). Blocked agents and red CI first.

**In flight** — severity 3. Uncommitted work, unpushed branches, draft PRs, stale
reviews. Group by repository so it reads as "this repo has three loose ends", not
as twelve separate facts.

**On the board** — Linear and calendar. What is assigned, what is scheduled.

## Naming things

**A bare identifier is never enough.** `SR-204`, `#2293`, `w8:p1` mean nothing on
their own, and a briefing whose reader has to open Linear to find out what it is
about has failed. Every first mention of a ticket, PR or pane carries a short
gloss — four to eight words, in your own compression, not the full title:

> `SR-204` — EtherFi severity recalibration
> `stakingrewards#2293` — custodial rating profiles + nav cleanup
> `w8:p1` — Sentio parallel backfills

Later mentions in the same briefing can use the bare id. Prefer the shared
paraphrase when a ticket, a branch, a pane and a PR are the same work — name the
work once, then list the ids that point at it.

Two things this is not: do not paste the full Linear or PR title verbatim (they
are written for a tracker, not a sentence), and do not spend a line explaining
something the gloss already covers.

**Today's three** — your recommendation: at most three things, in order, each
with a one-line reason drawn from the sections above. This is the only part of
the briefing where you have an opinion, so make it a real one: pick the thing
that unblocks the most other things, not the easiest thing. If a meeting eats the
morning, say what fits before it.

Housekeeping (severity 4) belongs in a single trailing line, if at all.

## 4. The pick-list

End with a numbered list of 3–5 concrete next actions, each mapped to how it
would run:

Each entry names what the work *is*, not just what it is called:

```
1. api-gateway#11 red CI — retry-budget tests failing      → implement
2. ledger#25 review requested — decimal rounding fix       → review
3. LG-204 rate-limit rework — no branch, no PR yet          → brainstorm
4. api-gateway: land the 2 uncommitted files               → implement
```

Then stop and wait. When the user picks a number, hand off to that workflow skill
(`brainstorm` / `plan` / `implement` / `review`) with the item as the brief. A
pick is an instruction to start work, so the isolation contract applies from that
moment: non-trivial work gets a worktree and a branch before the first commit.

## 5. Optional: publish it

If the day's picture is unusually busy, or the user asks for something to look
at, offer to publish the briefing as an Artifact. Do not publish unprompted — a
terminal briefing that the user reads and acts on in ten seconds does not need a
web page.

## Rules

- **Under about 40 lines** in the terminal. A briefing that scrolls is a briefing
  that gets skimmed.
- **Everything traceable.** Every claim comes from the collector, Linear, or the
  calendar. Never infer that something "probably needs attention".
- **No raw dumps.** No JSON, no full PR lists, no per-commit changelogs.
- **No bare identifiers.** See *Naming things* — every id gets a gloss on first
  mention.
- **Say what you could not see.** Missing `gh` auth, a stopped herdr server, an
  unreadable transcript — one line each under Notes. The collector's `errors`
  array is already that list.
- **Never echo credentials.** Transcript titles and commit subjects are quoted
  verbatim; if one contains something that looks like a token, redact it and flag
  it as a finding rather than reproducing it.
- **Do not act.** No git writes, no PR comments, no resuming sessions, no closing
  panes — until the user picks.

## When to skip this skill

The user asking a narrow question ("what's failing on PR 11?") wants that answer,
not a standup. Run the standup when they are *starting*, not when they are
already mid-thought.
