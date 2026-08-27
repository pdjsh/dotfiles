#!/usr/bin/env bash
# SessionStart hook: re-anchor the session on its task ledger.
#
# The reason this exists: after a compaction — or a resume the next morning — the
# conversation no longer remembers what was already done. The ledger does. This
# injects the board back into context so a long run picks up where it left off
# instead of redoing work or quietly dropping it.

set -uo pipefail

LEDGER="$HOME/.claude/bin/ledger"
[ -x "$LEDGER" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

export NO_COLOR=1
board=$("$LEDGER" board 2>/dev/null) || exit 0
[ -n "$board" ] || exit 0
path=$("$LEDGER" path 2>/dev/null || echo "~/.claude/ledgers/")

read -r -d '' ctx <<CTX || true
<active-ledger>
This session has an open task ledger. It — not the conversation — is the source of
truth for what has already been done and what is still open.

$board

File: $path

Keep it current, every time:
  ledger start <n>                       before you begin a task
  ledger note "<progress>"               at least every 20 minutes on a long task
  ledger done <n> "<evidence>"           when it is actually verified, with proof
  ledger block <n> "<why>" / drop <n> "<why>"
  ledger surface "<found, not fixing>"   instead of silently expanding scope
  ledger decide "<what>" --why "<why>"   for anything you chose on the user's behalf
  ledger wrap                            when the last task closes

If work starts that is not on this list, add it with \`ledger add\` first.
</active-ledger>
CTX

jq -n --arg ctx "$ctx" \
  '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$ctx}}'
