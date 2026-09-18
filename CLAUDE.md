# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

A Claude Code plugin marketplace + the one plugin it lists: a feature pipeline, a builder/
reviewer build-loop gate, and stack-knowledge skills for Umbraco package and backoffice
extension development (C#/.NET, EF Core, Lit + UUI). See [README.md](./README.md) for the
full skill list and [QUICKSTART.md](./QUICKSTART.md) for the install flow.

## This repo has no build, lint, or test step

Everything here is Markdown (skill/agent instructions) and two hand-written JSON manifests
(`.claude-plugin/marketplace.json`, `plugins/umbraco-claude-playbook/.claude-plugin/plugin.json`).
There is no source to compile and nothing to run. Before committing a manifest edit, check it
still parses:

```bash
jq . .claude-plugin/marketplace.json
jq . plugins/umbraco-claude-playbook/.claude-plugin/plugin.json
```

The two manifests duplicate each other's `description`/`version`/`keywords` for the one
plugin — if you change one, check whether the other drifted.

## This repo is not an Umbraco project

The skills here (`umbraco-extensibility`, `ef-core-data`, `umb-init`, etc.) describe conventions
for *consumer* projects that install this plugin — they don't apply to this repo's own
content. Don't reach for `dotnet build` or C# conventions on this repo itself; there's no
.NET code here.

## Architecture: one plan folder per feature, one file per owner

`umb-init` → `umb-explore` → `umb-design` → `umb-plan` → `umb-build-loop` each own one file
in a per-feature folder (default `docs/plans/<feature-slug>/`) in a *consumer* project — not
in this repo. The rules that make this work, if editing any of these skill files:

- **Re-entrant** — re-running a phase refines its file; it never restarts it.
- **One owner per file** — `umb-explore` owns `BRIEF.md`, `umb-design` owns `ARCHITECTURE.md`
  + `SPEC.md`, `umb-plan` owns `STORIES.md` + `PLAN.md`, `umb-build-loop` owns
  `BUILD-LOG.md`, every phase may append to `DECISION-LOG.md`. File-level (not
  section-level) ownership means two phases never touch the same file.
- **Stop, don't guess** — a phase missing its expected input hands off to the owning phase
  rather than inventing the missing content.

## Architecture: the builder/reviewer gate

`umb-build-loop` dispatches `agents/builder.md` per task, then `agents/reviewer.md` against
the diff. The split is load-bearing, not stylistic: `reviewer` has no `Edit`/`Write` in its
frontmatter `tools:` list, so it can only read, run builds/tests, and report a `PASS`/`FAIL`
verdict — a reviewer that can patch its own findings stops being a gate. `reviewer`'s
workflow order matters when editing it: diff → build/test → validate against docs first,
sibling code second → check impact on consumers (public API / manifest `alias` changes) →
trace the real entry point → grep for ghost code → multi-version/provider parity → verdict.

## Editing this repo's own skills

Changes here follow the same `git-workflow` skill this repo ships to others: Conventional
Commits, branch by change size, and — since this is a solo `main`-only repo right now — the
**always ask before committing straight to `main`** rule applies to you as much as to any
consumer project.

## Skill boundary discipline

Skill scope drifts quietly: `dotnet-conventions` ended up entirely Umbraco-specific despite its
generic name, `typescript-best-practices` absorbed Lit/Umbraco content, `security-dotnet`
picked up frontend XSS guidance, and two pairs of skills ended up documenting the same rule
twice — none of that was deliberate, it just accumulated one reasonable-looking edit at a time.

**Before adding a section to an existing skill, ask:**
1. Does this fit the skill's own frontmatter `description`? If not, that's a signal it
   belongs in a different (possibly new) skill, not a reason to broaden the description.
2. Is this generic language/stack discipline (portable to any project) or Umbraco/Lit-specific?
   Generic goes in a `*-best-practices` skill; Umbraco-specific goes in a skill named for what
   it actually covers.
3. Is this already documented elsewhere? Grep for the concept before writing it — this repo
   has twice ended up with the same rule stated in two skills because nobody checked first.

**Before renaming, splitting, or removing a skill,** run `scripts/check-skill-refs.sh` — it
flags any backtick-quoted skill reference across the repo's Markdown that no longer resolves
to an actual skill folder. It's a mechanical check for stale cross-references, not a judge of
whether a boundary is *correct* — the three questions above still need a real read of the
content, and a false positive gets added to `scripts/skill-ref-allowlist.txt`, not silenced by
weakening the check.
