#!/usr/bin/env bash
# Ensures a pattern (default: HANDOFF.md) is gitignored, so the handoff skill
# never leaves it in an accidental commit. No-op outside a git repo.
# Usage: ensure_gitignore.sh <dir> [pattern]
set -euo pipefail

DIR="${1:-.}"
PATTERN="${2:-HANDOFF.md}"

TOPLEVEL="$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null)" || { echo "not-a-git-repo"; exit 0; }

search="$(cd "$DIR" && pwd)"
found=""
while true; do
  if [ -f "$search/.gitignore" ]; then
    found="$search/.gitignore"
    break
  fi
  [ "$search" = "$TOPLEVEL" ] && break
  search="$(dirname "$search")"
done

if [ -z "$found" ]; then
  found="$TOPLEVEL/.gitignore"
  : > "$found"
  echo "created $found"
fi

if grep -qxF "$PATTERN" "$found" 2>/dev/null; then
  echo "already-ignored $found"
else
  printf '%s\n' "$PATTERN" >> "$found"
  echo "added $PATTERN to $found"
fi
