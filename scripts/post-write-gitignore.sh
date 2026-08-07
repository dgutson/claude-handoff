#!/usr/bin/env bash
# PostToolUse hook for the handoff plugin.
# Fires after every Write/Edit; if the touched file is a HANDOFF.md, makes
# sure it's gitignored. Fully mechanical — no model involvement, so it works
# no matter what wrote the file. Silent and a no-op in every other case.
set -euo pipefail

INPUT="$(cat)"

FILE_PATH="$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
print(d.get("tool_input", {}).get("file_path") or "")' 2>/dev/null || true)"

[ -z "$FILE_PATH" ] && exit 0
[ "$(basename "$FILE_PATH")" = "HANDOFF.md" ] || exit 0

"$(dirname "${BASH_SOURCE[0]}")/ensure_gitignore.sh" "$(dirname "$FILE_PATH")" >/dev/null 2>&1 || true
