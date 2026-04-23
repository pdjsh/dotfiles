#!/usr/bin/env bash
# PreToolUse hook: block `git commit` on master/main.
#
# Exits 0 to allow the tool call; 2 to block it (message goes to Claude via
# stderr). Scoped commits using `git -C <path>` are skipped — they target
# another worktree/path that we assume is intentional.

set -uo pipefail

input=$(cat)

tool_name=$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null || true)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)

[ "$tool_name" = "Bash" ] || exit 0

# Is there a `git commit` invocation in the command? (rough boundary match)
printf '%s' "$command" | grep -qE '(^|[;&|[:space:]])git[[:space:]]+commit([[:space:]]|$)' || exit 0

# Skip if the command uses `git -C <path>` — explicitly scoped to another dir.
if printf '%s' "$command" | grep -qE 'git[[:space:]]+-C[[:space:]]'; then
  exit 0
fi

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

if [ "$branch" = "master" ] || [ "$branch" = "main" ]; then
  cat >&2 <<EOF
BLOCKED: direct commits to '$branch' are disallowed by ~/.claude/CLAUDE.md workflow rule.

Create a feature branch (ideally in a worktree) first:
  git worktree add ../<repo>-<slug> -b feat/<slug>

Then commit in the worktree. If this commit really must land on $branch,
use an explicit path: \`git -C <path> commit ...\`.
EOF
  exit 2
fi

exit 0
