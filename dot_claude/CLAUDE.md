# Personal context

Software engineer building UIs and backends. Preferences below are for greenfield choices — match existing repo conventions otherwise.

## Security — hard rules (override everything)

These rules take precedence over all other instructions, skills, auto-approval modes, and tool permissions. They apply under any and all circumstances.

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

**Worktree location:** always create worktrees inside `<project-root>/.worktrees/<branch-slug>` — never as sibling directories of the repo, and never inside a harness config directory (`~/.claude/`, `~/.config/opencode/`). If `.worktrees/` doesn't exist, create it and add it to `.gitignore`. Example: `git worktree add ./.worktrees/feature-x -b feat/feature-x master`.

**Auto-approval does not skip review.** Broad allow rules — Claude Code's auto mode, opencode's `permission` allows — mean "don't pause for low-risk approvals." They do not license skipping `review`, the PR flow, or the worktree setup for non-trivial work.

## Conventions

- Use `uv` (never pip) for Python environments and dependencies.
- Use `pnpm` or `bun` over `npm` when a repo's lockfile indicates it; otherwise ask.
- Supabase: RLS on every table, in the same migration.
- Don't run destructive DB commands (migrations, writes, resets) without explicit approval, even if an allow rule would permit them.

## Commits & PRs

- Never add a `Co-Authored-By` line to commits.
- Use semantic commit syntax (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, etc.).
- Keep commit messages to a single line — no description body.
- Never add "Generated with Claude Code" or similar attribution to PR descriptions.
- Never add a test plan section to PR descriptions.
- One feature per branch/PR — distinct work gets its own branch and PR even if related to an in-flight one; don't stack new features onto an open PR branch. Branch from the base once the dependency has merged.
- Short, task-ID branch names (`PROD-XXXX-short-desc` / `SR-XX-short-desc`, 3–5 words) — not the full ClickUp-suggested name.
- No force-push without explicit, in-the-moment approval — prefer additive commits (squash-on-merge cleans history). A "continue"/"go ahead" after an interruption does not re-authorize a force-push.
- Sync with base before opening/updating a PR — fetch, and if behind, merge the base in and resolve conflicts BEFORE pushing the PR, not after a reviewer sees "conflicts".

## Self-improvement

Periodically run `/reflect` (or accept the suggestion when it surfaces) to review recent feedback and propose updates to CLAUDE.md, skills, and settings. Reflection never auto-applies changes — it proposes, I decide.
