#!/usr/bin/env bash
# SessionStart hook: inject a workflow-skill dispatcher at the top of
# every new / cleared / compacted session. Pattern adapted from
# obra/superpowers — pure prompt injection, no runtime enforcement.

set -euo pipefail

context='<EXTREMELY_IMPORTANT>
Before responding to any non-trivial coding task, invoke the relevant workflow skill via the Skill tool:

- brainstorm — open-ended scope, unclear requirements
- plan — concrete problem, no approved approach yet
- implement — approved plan, ready to execute (enforces worktree + feature branch)
- review — implementation done, before commit/PR (runs /review + /security-review + tests)
- reflect — at session start when feedback has accumulated

If there is even a 1% chance a workflow skill might apply, invoke it. Auto mode does not license skipping this check — auto skips approval gates, not review.

Red flags — these thoughts mean STOP and invoke the skill:
- "This is just a simple question" → check first
- "Let me explore the codebase first" → skills tell you how
- "I'\''ll just do this one thing first" → check BEFORE doing anything
- "I already know what to do" → invoke anyway, skills evolve

Never commit directly to master. Non-trivial work lives on a feature branch in a git worktree, created BEFORE the first commit.
</EXTREMELY_IMPORTANT>'

jq -n --arg ctx "$context" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'
