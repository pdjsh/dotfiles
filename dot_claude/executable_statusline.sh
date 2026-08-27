#!/usr/bin/env bash
# Status line: where you are, what model, and how far through the ledger.
#
#   ~/.config  ⎇ feat/agent-task-ledger  Opus 5   ▸ 4/9 wire the Stop hook
#
# The last segment is the point: at any moment, without scrolling, the current
# task and the remaining count are on screen.

set -uo pipefail

input=$(cat)
get() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

dir=$(get '.workspace.current_dir'); [ -n "$dir" ] || dir=$(get '.cwd'); [ -n "$dir" ] || dir="$PWD"
model=$(get '.model.display_name')

# Inside a repo, the repo name plus the branch says more than a 60-character
# worktree path ever does. Outside one, fall back to a ~-shortened tail.
branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
common=$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)
if [ -n "$common" ]; then
  short=$(basename "$(dirname "$common")")
else
  short=${dir/#$HOME/\~}
  case "$short" in
    */*/*/*) short=".../$(basename "$(dirname "$dir")")/$(basename "$dir")" ;;
  esac
fi

D=$'\033[2m'; R=$'\033[0m'; C=$'\033[36m'; Y=$'\033[33m'

out="${D}${short}${R}"
[ -n "$branch" ] && out="$out ${D}⎇ ${branch}${R}"
[ -n "$model" ] && out="$out ${D}${model}${R}"

LEDGER="$HOME/.claude/bin/ledger"
if [ -x "$LEDGER" ]; then
  status=$(cd "$dir" 2>/dev/null && NO_COLOR=1 "$LEDGER" status 2>/dev/null || true)
  if [ -n "$status" ]; then
    case "$status" in
      *blocked:*) out="$out  ${Y}${status}${R}" ;;
      *)          out="$out  ${C}${status}${R}" ;;
    esac
  fi
fi

printf '%s' "$out"
