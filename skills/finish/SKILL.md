---
description: Removes the HANDOFF.md that the handoff skill wrote, once its contents are no longer needed. Only run this when the user explicitly invokes it (e.g. /handoff:finish) — never invoke automatically, even right after reading one.
disable-model-invocation: true
---

Find `HANDOFF.md` in the current working directory (or wherever the user points you if they gave a path). If it doesn't exist, say so and stop — there's nothing to clean up.

If it exists, show the user a one-line reminder of what it's about (its `# Handoff: <topic>` title and `## Summary` are enough — don't paste the whole file back at them) and confirm they're done with it before deleting. They just ran this command on purpose, so a light confirmation is enough — don't turn it into a multi-step negotiation.

Once confirmed, delete the file. Don't archive it to some other location unless the user asks for that instead — the whole point is that a stale handoff sitting around (here or anywhere else discoverable) is what confuses the next session, and this repo's `SessionStart` hook will flag any `HANDOFF.md` it finds regardless of where it lives in the project.
