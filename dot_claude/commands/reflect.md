---
description: Review recent sessions, memory, and config. Propose targeted, evidence-backed changes to CLAUDE.md, skills, commands, or settings.
---

Invoke the `reflect` skill now.

Scan:
- Recent session transcripts under `~/.claude/projects/`
- Auto-memory entries under `~/.claude/projects/*/memory/`
- Global CLAUDE.md at `~/.claude/CLAUDE.md`
- User skills under `~/.claude/skills/`
- User commands under `~/.claude/commands/`
- Settings at `~/.claude/settings.json`

Produce the proposal format specified in the skill — a numbered list of changes, each with evidence and an explicit approval ask. Wait for user approval on each item before editing any file. Apply only what is approved, one at a time, confirming after each.
