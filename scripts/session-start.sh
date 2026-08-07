#!/usr/bin/env bash
# SessionStart hook for the handoff plugin.
# Read-only: looks for a leftover HANDOFF.md in the session's cwd. If one
# exists, prints a systemMessage so the user sees it immediately on launch
# (before typing anything), and separately primes Claude via additionalContext
# so that once the user does respond, Claude knows to ask before reading it
# rather than silently ingesting or silently ignoring it.
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
  CONTEXT="A HANDOFF.md exists at $HANDOFF — it may be left over from a previous session that wrapped up here. The user has already been shown a systemMessage about this at session start. Before doing anything else, ask whether they want you to read it now. Don't read it automatically: it could be stale or unrelated to what they're about to work on. If they confirm, read it and pick up from where it left off. Once its contents are no longer needed (the user says they're caught up, or they start unrelated work), mention that running /handoff:finish will remove it so it doesn't confuse a future session."
  MESSAGE="📋 Found HANDOFF.md from a previous session ($HANDOFF). Tell Claude to read it, or run /handoff:finish to discard it."

  CONTEXT="$CONTEXT" MESSAGE="$MESSAGE" python3 -c '
import json, os
print(json.dumps({
    "systemMessage": os.environ["MESSAGE"],
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": os.environ["CONTEXT"],
    }
}))
'
fi
