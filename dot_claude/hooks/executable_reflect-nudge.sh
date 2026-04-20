#!/bin/bash
# Nudges the user to run /reflect roughly every 20 session starts.
# Reads stdin (session start payload — ignored here) and writes a systemMessage
# every Nth time so the user sees a gentle reminder without feeling nagged.

COUNTER="$HOME/.claude/.reflect-counter"

N=$(cat "$COUNTER" 2>/dev/null || echo 0)
N=$((N + 1))
echo "$N" > "$COUNTER"

if [ $((N % 20)) -eq 0 ]; then
  echo '{"systemMessage": "Heads-up: it has been ~20 sessions since the last reflection. Consider running /reflect to review your config."}'
fi

exit 0
