---
name: supabase
description: Use when working on Supabase-related code — RLS policies, SQL migrations under supabase/migrations/, auth flows with @supabase/ssr, typegen, Edge Functions, or queries via supabase-js. Covers local dev workflow (supabase CLI), migration conventions, RLS-first design, and the danger list of commands that mutate remote databases.
---

# Supabase

Supabase is the user's default for personal projects. This skill covers conventions that are easy to get wrong.

## RLS is not optional

Every table has Row Level Security enabled, and policies are defined **in the same migration that creates the table**. Never ship a table with RLS disabled, and never "we'll add policies later."

When creating a table:

```sql
create table public.foo (...);
alter table public.foo enable row level security;
create policy "users read own foo" on public.foo
  for select using (auth.uid() = user_id);
-- ...one policy per action (select / insert / update / delete), or `for all`
```

If the brainstorm phase didn't nail down who can read/write the new table, that's a blocker — go back and clarify before writing the migration.

## Migration workflow

1. **Write SQL locally** under `supabase/migrations/YYYYMMDDHHMMSS_description.sql`. Never modify an applied migration — write a new one instead.
2. **Test locally:** `supabase db reset` rebuilds from scratch. If the migration is wrong, fix it and reset again — this is free while local.
3. **Regen types:** `supabase gen types typescript --local > <types-path>`. Exact path varies per project (often `src/lib/database.types.ts` or `types/supabase.ts`).
4. **Apply to remote:** `supabase db push`. **Requires explicit user approval** — this is destructive-class.

## Danger list (always prompt, never auto-approve)

These commands mutate the remote database or lose work:

- `supabase db push` — applies migrations remotely
- `supabase db reset` — rebuilds from migrations (wipes data)
- `supabase migration repair` — rewrites migration history
- `supabase migration apply` — on remote
- Any raw `psql` / `supabase db execute` with `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE`, `CREATE`, `GRANT`
- Seed script changes that run on `db reset` — flag the seed file diff explicitly

Read-only inspection is fine: `supabase status`, `supabase db diff`, `supabase migration list`, `SELECT …` queries.

## Policy patterns

- `auth.uid()` is the authenticated user's UUID. Most policies key off it.
- `SELECT` / `INSERT` / `UPDATE` / `DELETE` each need their own policy unless using `FOR ALL`.
- `INSERT` policies use `with check` (not `using`).
- `UPDATE` policies need both `using` (pre-image) and `with check` (post-image).
- Admin / service-role access: handle via `auth.jwt()->>'role'` or a dedicated function — never disable RLS.
- Test policies against realistic auth contexts; `supabase/tests/` (pgTAP) is the canonical pattern.

## Auth (Next.js apps)

- Use `@supabase/ssr` (cookie-based), not the bare `supabase-js` client with `localStorage`.
- **Client side:** `createBrowserClient` — uses cookies set by server.
- **Server side:** `createServerClient` with the cookies helper — different instance per request.
- **Route handlers / middleware:** use `createServerClient` with the appropriate cookies shim.
- **Never expose the service role key to the browser.** Service role work goes in Edge Functions or server actions.

## Edge Functions

- Deno runtime, ESM imports via URLs (`import { serve } from "https://deno.land/std/http/server.ts"`).
- `supabase functions deploy` mutates prod — **prompt before deploying**.
- Secrets via `supabase secrets set` (not committed).
- CORS must be handled explicitly — Edge Functions don't inherit Next.js middleware.

## Typegen reminder

If a migration changed a schema, regen types *before* running the frontend or you'll chase phantom TypeScript errors that are actually stale types. Add this to the test plan for any migration.

## Common mistakes

- Writing a policy that references `auth.uid()` on a column that allows nulls → grant test fails silently. Narrow the column to `not null`.
- Forgetting `enable row level security` → table is readable by anyone with `anon` access. Always pair table creation with `enable row level security`.
- Using `service_role` in client code "just to get it working" — blocks the user from catching auth bugs. Never.
- Editing a migration already pushed to remote → remote and local drift. Write a new migration instead.
