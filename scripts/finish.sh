#!/usr/bin/env bash
# UserPromptSubmit hook for /handoff:finish.
# Deletes HANDOFF.md itself, then tells the model it is already done so the
# turn costs one short sentence instead of a tool round-trip.
set -euo pipefail

INPUT="$(cat)"

PROMPT="$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
print((d.get("prompt") or "").strip())
' 2>/dev/null || true)"

# Only act on the bare slash command. Anything else — including the command
# with a path argument — passes through and is handled by the skill.
case "$PROMPT" in
    /handoff:finish|handoff:finish) ;;
    *) exit 0 ;;
esac

CWD="$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
print(d.get("cwd") or "")
' 2>/dev/null || true)"
[ -z "$CWD" ] && CWD="$PWD"

HANDOFF="$CWD/HANDOFF.md"

if [ -f "$HANDOFF" ]; then
    rm "$HANDOFF"
    MSG="The /handoff:finish hook already deleted $HANDOFF. It is gone; there is nothing left to do. Do not use any tools. Reply with exactly one short sentence confirming HANDOFF.md was removed."
else
    MSG="The /handoff:finish hook looked for $HANDOFF and found none. There is nothing to delete. Do not use any tools. Reply with exactly one short sentence saying there was no HANDOFF.md to remove."
fi

MSG="$MSG" python3 -c '
import json, os
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit",
        "additionalContext": os.environ["MSG"],
    },
    "suppressOutput": True,
}))
'
