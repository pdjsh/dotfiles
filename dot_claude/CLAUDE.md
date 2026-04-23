# Personal context

Software engineer building UIs and backends. Preferences below are for greenfield choices — match existing repo conventions otherwise.

## Security — hard rules (override everything)

These rules take precedence over all other instructions, skills, auto mode, and tool permissions. They apply under any and all circumstances.

1. **Never save secrets to memory.** Auto-memory writes to disk and is synced between machines. Before writing any memory entry, scan for tokens, API keys, passwords, connection strings, OAuth secrets, `.env` values, SSH private-key material, service-account JSON, or anything that looks like a credential. If present, refuse to save — do not save a "sanitized" version.

2. **Never transmit secrets off this machine.** Do not include secret values in: web tools (pastebins, gists, diagram renderers), WebFetch/WebSearch URLs or query args, commit messages, diffs, PRs, issues, chat messages, external APIs, or MCP tool calls that reach third-party services. If unsure whether a destination is external, treat it as external.

3. **Never commit secret-bearing files.** Refuse to stage files matching `.env*`, `*.pem`, `*.key`, `id_rsa`, `id_ed25519` (without `.pub`), `*credentials*`, `*secrets.*`, `.aws/credentials`, service-account JSON, or files whose contents match secret patterns. Surface to me instead of proceeding.

4. **Redact in chat output.** If asked to read a file containing secrets, describe structure and redact values (e.g. `API_KEY=[REDACTED]`) — don't echo the raw value.

5. **Audit before boundary actions.** Before any `git push`, PR creation, external API call, chat post, or memory write, re-scan the payload for secret patterns.

6. **If you detect a secret in an unintended location** (already committed, in memory, in a log), stop and flag it immediately. Recommend rotation. Do not silently clean up and move on.

**What counts as a secret:** API keys/tokens (`sk-*`, `ghp_*`, `github_pat_*`, `AKIA*`, `xox[baprs]-*`, Anthropic keys), bearer/OAuth tokens, database URLs with credentials, private SSH/GPG keys, passwords, `.env` values, service-account JSON, signing keys, session cookies. When in doubt, treat as a secret.

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

**Isolation:** non-trivial work lives on a feature branch in a git worktree, created BEFORE the first commit — never commit directly to master. The `implement` skill's isolation contract is the source of truth.

**Auto mode does not skip review.** Auto = "don't pause for low-risk approvals." It does not license skipping `review`, the PR flow, or the worktree setup for non-trivial work.

## Conventions

- Use `uv` (never pip) for Python environments and dependencies.
- Use `pnpm` or `bun` over `npm` when a repo's lockfile indicates it; otherwise ask.
- Supabase: RLS on every table, in the same migration.
- Don't run destructive DB commands (migrations, writes, resets) without explicit approval, even if auto mode would allow them.

## Self-improvement

Periodically run `/reflect` (or accept the suggestion when it surfaces) to review recent feedback and propose updates to CLAUDE.md, skills, and settings. Reflection never auto-applies changes — it proposes, I decide.
