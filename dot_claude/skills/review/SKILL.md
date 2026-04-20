---
name: review
description: Use after implementation is complete, before the user commits, merges, or the PR is opened. Runs a self-review pass, invokes /review and /security-review, runs the relevant test suite, checks documentation for any public API changes. Surfaces findings as a punch list. For autonomous flows, review happens before the PR is raised so findings go into the PR description.
---

# Review

Implementation is done. Before the work reaches the user (as a PR or a commit they'll push), do a structured review pass. The review's job is to catch anything the user would otherwise have to catch — so they can skim rather than dig.

## Pass 1: self-review

Re-read the full diff as if you didn't write it.

- Is every change consistent with the plan?
- Is anything in the diff *not* in the plan? (Flag as scope creep.)
- Are there leftover debug prints, `console.log`, commented-out code, stray TODOs?
- Does the code match project style and CLAUDE.md conventions?
- Obvious bugs — null / undefined handling, off-by-ones, unhandled promise rejections, missing `await`, SQL injection risk, XSS risk?
- Type safety — any `any` / `unknown` that should be narrowed?
- Error handling — boundaries handled at the right layer (not smothered internally)?

## Pass 2: tests

Run the relevant test suite (`pytest`, `npm test`, `bun test` — whatever the repo uses). For modules you touched:

- Existing tests must pass.
- New behavior → write tests for the golden path plus at least one edge case.
- Refactor with no behavior change → tests optional; say so explicitly.

If tests failed, fix them before anything else and note what broke.

## Pass 3: built-in tools

Invoke `/review` (general code review) and `/security-review` (security pass). For autonomous flows, these can run as parallel background subagents — collect findings before composing the PR description.

Filter findings: not every "suggestion" is worth the user's time. Promote real issues to the punch list; set aside nits or flag them as nits.

## Pass 4: docs

If any public API, config shape, or user-facing behavior changed:

- Was it documented somewhere a reader would find?
- Update existing README / docs files in place.
- Do **not** invent new docs files that weren't there before — the user hasn't asked for them.

## Output — the punch list

Hand the user a walkable punch list. Example:

```
## Review summary

**Verified:**
- All 14 tests pass (added 3 for new behavior)
- No scope creep; diff matches the plan
- /security-review: no findings
- Types: clean, no `any` introduced

**Open items:**
- ⚠️  [blocker] RLS policy missing on `orders` table — will not ship without approval
- 🔸 [nit] `app/api/foo/route.ts:42` has unused import — auto-fix suggested
- 🔸 [doc] Consider a line in `README.md` on the new `/api/foo` endpoint

**Next actions:**
- Approve or request changes on the PR
```

For autonomous flows, this punch list goes into the PR description, not a chat message. The user sees it when they open the PR.

## Rules

- **Never commit, merge, or close for the user** — review produces findings; the user acts on them.
- **Blockers must actually block.** If something is a blocker, say so clearly. If it's a nit, call it a nit — don't conflate.
- **Silence is bad.** "No findings" is a valid report; no report is not.
