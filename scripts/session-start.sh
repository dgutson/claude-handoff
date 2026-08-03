#!/usr/bin/env bash
# SessionStart hook for the handoff plugin.
# Read-only: looks for a leftover HANDOFF.md in the session's cwd and, if one
# exists, tells Claude (via additionalContext) to offer reading it rather than
# silently ingesting it or silently ignoring it.
set -euo pipefail

INPUT="$(cat)"

CWD="$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
print(d.get("cwd") or d.get("workspace", {}).get("current_dir") or "")' 2>/dev/null || true)"
[ -z "$CWD" ] && CWD="$PWD"

HANDOFF="$CWD/HANDOFF.md"

if [ -f "$HANDOFF" ]; then
  CONTEXT="A HANDOFF.md exists at $HANDOFF — it may be left over from a previous session that wrapped up here. Before doing anything else, tell the user it's present and ask whether they want you to read it now. Don't read it automatically: it could be stale or unrelated to what they're about to work on. If they confirm, read it and pick up from where it left off. Once its contents are no longer needed (the user says they're caught up, or they start unrelated work), mention that running /handoff:finish will remove it so it doesn't confuse a future session."

  CONTEXT="$CONTEXT" python3 -c '
import json, os
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": os.environ["CONTEXT"],
    }
}))
'
fi
