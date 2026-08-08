# handoff

A Claude Code plugin that wraps up a session into a `HANDOFF.md` before you
start a fresh chat, so context resets don't mean starting over.

## The problem

Long sessions eventually run low on context — or you just want to close one
out and continue later. Starting a brand-new chat is easy; recovering
everything that mattered in the old one usually isn't. Findings, dead-end
experiments, decisions you already made, and the exact next step all live
only in a conversation you're about to leave behind.

## How this fixes it

- **`handoff` skill** — triggers when you say things like "context's getting
  low", "wrap this up", "start a fresh chat", or invoke `/handoff` directly.
  Writes a `HANDOFF.md` (default: current directory) with a fixed structure —
  Summary, Findings, Experiments tried, Conclusions/decisions, Open questions
  & remaining tasks — written for a fresh Claude Code session with zero
  memory of the old conversation to read cold. If a `HANDOFF.md` already
  exists (a chain of handoffs), it's overwritten with resolved items dropped
  and still-open ones carried forward — never left as a growing pile of
  `HANDOFF-2.md`-style variants.
- **`SessionStart` hook** — every new session checks the working directory
  for a leftover `HANDOFF.md`. If one's there, you see a message about it
  immediately on launch, before typing anything — it also primes Claude so
  that once you do respond, it asks before reading it rather than silently
  ingesting or silently ignoring it, since it might be stale or unrelated to
  what you're about to do next.
- **`PostToolUse` hook** — after any `Write`/`Edit` to a file named
  `HANDOFF.md`, automatically adds it to `.gitignore` (creating one if
  needed), so this personal, session-specific file never gets committed by
  accident. Pure script, no model involvement — it fires no matter what
  created the file, and costs no tokens.
- **`/handoff:finish` command** — once a `HANDOFF.md` has served its purpose,
  this removes it. A leftover handoff file is exactly the kind of stale
  context that confuses a later, unrelated session; this is the explicit
  cleanup step so it doesn't linger.

## Install

```
/plugin marketplace add dgutson/claude-handoff
/plugin install handoff@claude-handoff-marketplace
/reload-plugins
```

**Pick your scope deliberately.** `/plugin install` asks for `user`, `project`
or `local`; **`user` is almost always what you want.** The plugin's trigger
isn't a particular repo, it's "this session ran long" — and you don't know in
advance which project that will be. At `project` or `local` scope everything is
gated to one repo: the `handoff` skill and `/handoff:finish` don't exist
elsewhere, and the `SessionStart` hook won't fire, so a leftover `HANDOFF.md`
in any other directory goes silently unannounced. From the shell:

```
claude plugin install handoff@claude-handoff-marketplace --scope user
```

`project` scope is worth it only when you want the convention committed for a
whole team on one repo; `local` when you're trialling it on a single repo. To
check what you got, look for `"scope": "user"` under
`handoff@claude-handoff-marketplace` in
`~/.claude/plugins/installed_plugins.json`.

## Usage

```
# near the end of a long session
"context is getting really low, can you wrap this up?"
# or explicitly
/handoff
```

Claude writes `HANDOFF.md`, tells you where, and reminds you there's no way
for it to restart the session on its own — run `/clear` or open a new
session yourself, then reference the file (paste its path or `@`-mention it)
so the fresh session reads it first.

Once you're caught up and no longer need it:

```
/handoff:finish
```

## What this doesn't do

It can't restart or clear the session for you — no tool exposed to Claude
Code (or a plugin) can do that from inside a running session. `/clear` /
opening a new chat stays a manual step.

## Requirements

- `python3` (used by the hooks to parse/emit JSON).
- `git` (only needed for the `.gitignore` behavior; a no-op outside a repo).

## License

MIT — see [LICENSE](LICENSE).
