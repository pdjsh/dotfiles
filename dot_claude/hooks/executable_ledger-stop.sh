#!/usr/bin/env bash
# Stop hook: show the board at the end of every turn, and refuse to let a run
# end mid-task or unwrapped.
#
# Two jobs:
#   1. Visibility — print the task board whenever it changed this turn, so the
#      human never has to scroll back through tool calls to find out where things
#      stand.
#   2. Hygiene — if `ledger doctor` reports a blocker (a task in progress with no
#      update for 20+ minutes, or every task closed with no wrap-up), send the
#      agent back once to reconcile. `stop_hook_active` guarantees at most one
#      extra round-trip, so this can never loop.

set -uo pipefail

LEDGER="$HOME/.claude/bin/ledger"
STATE="$HOME/.claude/ledgers/.last-board"
[ -x "$LEDGER" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
stop_active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null || echo false)

export NO_COLOR=1
board=$("$LEDGER" board 2>/dev/null) || exit 0
[ -n "$board" ] || exit 0

warnings=$("$LEDGER" doctor --json 2>/dev/null || echo '[]')
blockers=$(printf '%s' "$warnings" | jq -r '[.[] | select(.level=="block") | "- " + .msg] | .[]' 2>/dev/null)

if [ -n "$blockers" ] && [ "$stop_active" != "true" ]; then
  printf '%s' "$board" > "$STATE" 2>/dev/null || true
  reason=$(cat <<MSG
Before this turn ends, reconcile the task ledger:

$blockers

$board

Close, split, block or note the task — then give the user the wrap-up. Do not
leave a task in progress with nothing recorded against it.
MSG
)
  jq -n --arg r "$reason" '{decision:"block", reason:$r}'
  exit 0
fi

# Only speak up when something actually moved. An unchanged board is already on
# screen a few lines up; repeating it every turn trains the user to ignore it.
if [ -f "$STATE" ] && [ "$(cat "$STATE" 2>/dev/null)" = "$board" ]; then
  exit 0
fi
printf '%s' "$board" > "$STATE" 2>/dev/null || true

jq -n --arg m "$board" '{systemMessage:$m}'
