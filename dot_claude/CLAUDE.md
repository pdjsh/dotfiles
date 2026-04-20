# Personal context

Software engineer building UIs and backends. Preferences below are for greenfield choices — match existing repo conventions otherwise.

## Preferred stack

**Frontend (greenfield TS/React):** Next.js, TypeScript, shadcn/ui, Tailwind, TanStack Query, Framer Motion.

**Backend (greenfield Python):** uv (never pip), ruff for lint + format, pytest, pyright. Pydantic when data models are non-trivial.

**Personal projects:** Supabase is the default — RLS policies written alongside every new table, not added later.

## Workflow

Work in phases driven by skills, not explicit commands:

- **brainstorm** for open-ended problems → clarify scope first
- **plan** once the problem is concrete → propose + wait for approval
- **implement** once approved → tight scope, no boy-scouting
- **review** before I commit → tests, docs, security pass

Trivial fixes can skip brainstorm/plan. Non-trivial changes should not.

## Conventions

- Use `uv` (never pip) for Python environments and dependencies.
- Use `pnpm` or `bun` over `npm` when a repo's lockfile indicates it; otherwise ask.
- Supabase: RLS on every table, in the same migration.
- Don't run destructive DB commands (migrations, writes, resets) without explicit approval, even if auto mode would allow them.

## Self-improvement

Periodically run `/reflect` (or accept the suggestion when it surfaces) to review recent feedback and propose updates to CLAUDE.md, skills, and settings. Reflection never auto-applies changes — it proposes, I decide.
