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

The skills here (`dotnet-conventions`, `ef-core-data`, `umb-init`, etc.) describe conventions
for *consumer* projects that install this plugin — they don't apply to this repo's own
content. Don't reach for `dotnet build` or C# conventions on this repo itself; there's no
.NET code here.

## Architecture: one plan doc per feature, five owners

`umb-init` → `umb-explore` → `umb-design` → `umb-plan` → `umb-build-loop` each own one
section of a single per-feature file (default `docs/plans/<feature-slug>-plan.md`) in a
*consumer* project — not in this repo. The rules that make this work, if editing any of
these skill files:

- **Re-entrant** — re-running a phase refines its section; it never restarts the file.
- **One owner per section** — `umb-explore` owns `## Problem`/`## Non-goals`, `umb-design`
  owns `## Design`, `umb-plan` owns `## Stories & Tasks`, `umb-build-loop` owns
  `## Build Log`, every phase may append to `## Decision Log`.
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
