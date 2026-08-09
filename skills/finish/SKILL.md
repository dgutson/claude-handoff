---
description: Removes the HANDOFF.md that the handoff skill wrote, once its contents are no longer needed. Only run this when the user explicitly invokes it (e.g. /handoff:finish) — never invoke automatically, even right after reading one.
---

A `UserPromptSubmit` hook usually handles this before you are invoked. If the injected context says the hook already deleted `HANDOFF.md` (or already found none), that is done — do not use any tools, just confirm it in one short sentence.

Otherwise — typically because the user pointed at a specific path — find that `HANDOFF.md`, delete it, and confirm. If it doesn't exist, say so.
