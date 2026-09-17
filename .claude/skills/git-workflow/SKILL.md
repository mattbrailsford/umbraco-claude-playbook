---
name: git-workflow
description: >-
  Conventional Commits, trunk-vs-branch by change size, and how an Umbraco package's own
  versioning relates to the CMS major versions it supports. Use whenever committing,
  branching, or deciding how to structure either for a change in an Umbraco project. Does
  not cover release pipelines — see the README's "Building on top" section for that.
---

# Git workflow

Write commits and branches that read clearly weeks later. Direct, specific, no filler.

## Branching — when to branch, when not

**Trunk-based (commit straight to the default branch)** when:
- Single-file or single-concept fix.
- Typo, doc tweak, version bump, comment, lint fix.
- Test-only addition that doesn't change behavior.
- Reviews itself in 30 seconds, one commit.

**Short-lived branch** when:
- More than ~2 commits expected.
- New feature or capability, even a small one.
- A schema/migration change.
- Anything that could break the default branch for someone else.
- A task with its own id in a feature's `## Stories & Tasks` section.

Branch naming: `<type>/<short-slug>` — `feat/order-fulfillment`, `fix/missing-null-check`,
`chore/bump-deps` — for a project supporting a single CMS version line. **Supporting more
than one Umbraco CMS major at once? Prefix with the version instead** (see "Umbraco packages
and version tracking" below) — `v17/fix/missing-null-check`, `v18/feature/order-fulfillment`.
Prefer the `vN/` **prefix** form for a new project (it sorts and greps better than a suffix);
match whatever a project with existing history already does otherwise. Keep branches
short-lived; open the PR early, even as draft.

## If you are an AI agent: always ask before touching main or a support branch

"Trunk-based" above is about when a *human* would commit straight to the default branch — it
is not permission for an agent to do the same thing unattended. Before running `git commit`
or `git merge` directly against the default branch or a `support/*`-style branch, **stop and
ask the user to confirm first**, however trivial the change looks. A mis-scoped "trivial"
commit on a protected branch is cheap to avoid by asking, expensive to unwind after.

## Commits — Conventional Commits, kept honest

**Use Conventional Commits.** It costs nothing to adopt, buys machine-parseable changelogs
and automated version bumps the moment you want them, and `fix(profile): ...` is easier to
scan six months later than `Fix: some things`. **The one carve-out:** don't retrofit an
established repo's *existing* history — start applying it going forward, and match a repo's
already-active, deliberate house style if it has one that isn't Conventional Commits.

```
<type>(<optional scope>): <imperative summary, lower-case, no period>

<body — what changed and why, wrapped at ~72 cols>

<footer — refs, breaking changes>
```

**Types:** `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `build`, `ci`,
`revert`.

**Summary rules:** 50 chars or fewer when possible, hard cap 72. Imperative mood (`add`, not
`added`/`adds`). No trailing period. Scope is optional, use it when there's an obvious area.

**Body rules:** include one if the change isn't self-evident from the diff. Explain *what*
and *why*, never restate the diff line by line. Reference issues with `Refs #123` /
`Closes #123`.

**Good:**
```
fix(profile): resolve connection by alias before validating capability

The capability check ran before the connection lookup, so a missing
connection surfaced as "capability not supported" instead of "connection
not found" — misleading for anyone debugging a typo'd alias.

Refs #142
```

**Bad:** `fix stuff` · `WIP` · `Update ProfileService.cs` (says nothing the diff doesn't) ·
`Added some changes and refactored a couple of things` (vague, past tense).

## Issues — `gh issue create`

A useful issue answers: **what's wrong / what's wanted, what's the context, what does done
look like.**

```markdown
## Context
<one paragraph: where this came from, why it matters, link to a story id or plan-doc
section if relevant>

## What we want
<the concrete change or behavior — bulleted is fine>

## Acceptance criteria
- [ ] <observable outcome 1>
- [ ] <observable outcome 2>

## Notes
<optional — links, screenshots, related PRs>
```

```bash
gh issue create \
  --title "feat(profile): resolve connection by alias before validating capability" \
  --body "$(cat <<'EOF'
## Context
...
EOF
)"
```

Add labels if the repo uses them (`--label bug`), and an assignee if known (`--assignee @me`).

## Pull requests — `gh pr create`

A useful PR answers: what changed, why, how to verify, what could go wrong.

```markdown
## Summary
- <headline change>
- <caveats / non-changes>

## Why
<one paragraph — the motivation, linked story/issue>

## How to verify
- [ ] <a concrete check, ideally a command>

## Risk / rollback
<what could go wrong, how to revert>

Closes #<issue-number, if any>
```

Command (always use a HEREDOC for the body — preserves formatting):

```bash
gh pr create \
  --title "feat(profile): resolve connection by alias before validating capability" \
  --body "$(cat <<'EOF'
## Summary
- ...

## Why
...

## How to verify
- [ ] dotnet test ...

## Risk / rollback
Low — revert via git revert.

Closes #142
EOF
)"
```

Title follows whatever commit convention the project uses (see above — Conventional Commits
or the looser `Area: description` style), same as a commit summary, and should reflect *all*
the commits on the branch, not just the latest. If the branch isn't pushed yet, push it first:
`git push -u origin HEAD`. Use `--draft` for a draft PR, `--base <branch>` for a non-default
target.

## Sanity rules

- Don't push to the default branch with `--force`. Ever.
- Don't `--no-verify` to skip hooks unless explicitly asked.
- Never commit secrets — re-check the diff for `.env` files, tokens, and keys before staging.
- Never commit large binaries or `node_modules`/`bin`/`obj` — confirm `.gitignore` covers
  them.
- If `git status` shows untracked files you didn't expect, investigate before staging — it
  could be someone else's in-progress work.

## Umbraco packages and version tracking

A package's own version and the Umbraco CMS major version(s) it supports are two different
numbers, and conflating them causes real problems — a package pinned to `18.x` because it
happens to be at `v18` of its *own* versioning, when it actually still works fine against
CMS v17, needlessly locks out v17 sites. Track both, deliberately:

- **The package's own SemVer** (what you commit and tag) and **the CMS major(s) it declares
  support for** are separate facts. Express the CMS constraint as a package-level version
  range in your dependency management (e.g. `[17.0.0, 19.0.0)` against the CMS package), not
  as an assumption baked into code. When a change only applies to one CMS major, say so
  explicitly in the commit body and PR description — a reviewer on a multi-version project
  can't infer that from the diff alone.
- **Which CMS major(s) does this support right now**, and which lifecycle phase is each one
  in (active feature development, security-patches-only, or end-of-life)? Umbraco's own
  [LTS/EOL policy](https://umbraco.com/products/knowledge-center/long-term-support-and-end-of-life/)
  is the reference point for what those phases mean.

**If more than one CMS major is supported at once**, decide early — before it's forced by a
merge conflict — how the codebase carries that:

- **Branch-per-major** (recommended default): each major gets its own long-lived line, and a
  fix that applies to more than one is ported deliberately. Avoids runtime version-check
  complexity, at the cost of porting shared fixes across branches by hand. Naming:
  `support/N.x` alongside a single `main` is the older shape; `vN/dev` + `vN/main` per line
  (with `vN/feature/…`, `vN/release/…`, `vN/hotfix/…` underneath) is the newer one worth
  defaulting to — it makes which lines exist and their state visible from the branch list
  alone.
- **Single branch with runtime version checks** (`if (umbracoMajorVersion >= N) { ... }`):
  keeps everything in one place, but the checks accumulate and untested branches-not-taken
  creep in. Reasonable only for a package needing a handful of such checks at most.

This skill deliberately stops here. A full release pipeline — calendar-based release
branches, multi-product release manifests, automated changelog generation, coordinated
releases across more than one package — is a "build on top" concern once a project's needs
actually require it. See the README's **Building on top** section for what that looks like
in practice.
