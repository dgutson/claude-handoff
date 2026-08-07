---
name: handoff
description: Wraps up the current session into a HANDOFF.md so the user can start a brand-new chat without losing context. Use this whenever the user wants to end the session and continue later, says context is running low / getting full / almost out of context, asks to "wrap up", "start fresh", "start a new chat", "summarize this session", or invokes /handoff directly. Also worth suggesting proactively if the user mentions the conversation has gotten very long and they're about to open a new one. Do not confuse this with committing code or writing a PR description — this is about preserving the session's own findings, experiments, conclusions, and open work, not the diff.
---

Write a `HANDOFF.md` (ask where, default to the current working directory) that lets a fresh chat pick up exactly where this one left off. The person reading it is a new Claude Code session with zero memory of this conversation — write for that reader, not for a human skimming notes.

Before writing, run `${CLAUDE_PLUGIN_ROOT}/scripts/ensure_gitignore.sh <target-dir>` — it gitignores `HANDOFF.md` (creating a `.gitignore` if needed) so this personal, session-specific file never gets committed by accident. It's a no-op outside a git repo and idempotent otherwise, so just run it and move on; no need to narrate the result to the user.

Compose it entirely from what's already in your context (the conversation so far, any earlier auto-summarized portions, and prior tool results) — don't go re-reading transcript files or re-running commands to reconstruct it. This skill tends to get invoked exactly when context is tightest, so keep tool calls minimal.

If a `HANDOFF.md` already exists at the target path, this is a chain of handoffs — the current session likely started by reading it, so its content is already folded into your context. Overwrite it with a new one rather than appending or naming a variant like `HANDOFF-2.md`: there should only ever be one live handoff doc, or old and new versions will contradict each other and it won't be obvious which to trust. When overwriting, carry forward anything from the old file that's still true and unresolved (an open question doesn't disappear just because it wasn't discussed again this session) and drop what this session already resolved.

Use this structure, and cut any section that's genuinely empty rather than padding it:

```markdown
# Handoff: <one-line topic>

## Summary
2-4 sentences: what this session was about and where it stands right now.

## Findings
What was discovered/learned, stated as facts with locations (file:line, command output, URLs). Not "explored the auth code" — "session tokens are stored in plaintext in redis, see auth/session.py:88".

## Experiments tried
What was attempted and what happened, including dead ends. A future session should not have to redo something that already failed here. State the approach and its outcome together, e.g. "Tried X → failed because Y" — not two disconnected lists.

## Conclusions / decisions
Judgment calls made and why, and anything the user explicitly confirmed or rejected.

## Open questions & remaining tasks
Concrete next actions and unresolved questions, in the order they should probably be tackled. Flag anything blocked and on what.
```

Be concrete, not comprehensive — a fresh session needs to reconstruct working context fast, not read a transcript replay. Skip pleasantries, skip anything that's obvious from the code/repo itself (the next session can read files), and skip praise or process narration ("I then used the Bash tool to..."). Include exact file paths, commands, decisions, and numbers wherever you have them, since those are what saves the next session from redoing work.

After writing the file, tell the user directly:
- Where the file was written.
- That there's no way to restart the session for them — they need to run `/clear` or open a new session themselves, then reference this file (paste its path, or `@`-mention it) so the fresh session reads it before doing anything else.
- That once the fresh session has picked up from it and it's no longer needed, running `/handoff:finish` removes it — a leftover `HANDOFF.md` is exactly the kind of stale file that confuses a later, unrelated session (this plugin's `SessionStart` hook will flag it either way, but it's better cleaned up than left for that).
