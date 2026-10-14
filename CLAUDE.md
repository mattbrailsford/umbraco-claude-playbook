# CLAUDE.md

Guidance for Claude Code when working in this repository.

This repo is a Claude Code plugin marketplace plus the one plugin it lists: a feature
pipeline, a builder/reviewer build-loop gate, and stack-knowledge skills for Umbraco package
and backoffice extension development (C#/.NET, EF Core, Lit + UUI).

## Layout

```
.claude-plugin/marketplace.json                   # marketplace manifest (lists the plugin)
plugins/umbraco-claude-playbook/
  .claude-plugin/plugin.json                      # plugin manifest
  skills/<name>/SKILL.md                          # one folder per skill (+ references/, templates/)
  agents/{builder,reviewer,issue-triager}.md      # subagents
settings.example.json   # copy-by-hand example for consumers; NOT installed by the plugin
scripts/                # check-*.sh + the refs allowlist; repo-only, not shipped
.claude/skills/review-skill-links/  # repo-only skill: cross-reference review; not shipped
docs/HOW-IT-WORKS.md    # human explainer: plan folder, gate, memory, branches
docs/pr-examples/       # images used in PR descriptions; not shipped
README.md, QUICKSTART.md  # human-facing; see "Human docs" below
```

## No build, lint, or test step

Everything is Markdown plus two hand-written JSON manifests. There is no .NET code here.
Don't run `dotnet build` or apply C# conventions to this repo. Checks that do exist:

```bash
jq . .claude-plugin/marketplace.json
jq . plugins/umbraco-claude-playbook/.claude-plugin/plugin.json
scripts/check-skill-refs.sh   # stale backtick skill references; exit 1 = needs a look
scripts/check-skill-wiring.sh # every skill in the README and referenced from elsewhere
scripts/check-version.sh      # version fields agree, and bumped if shipped files changed
scripts/check-frontmatter.sh  # skill/agent headers parse, names match, descriptions fit
```

## This repo is not an Umbraco project

Skills like `umbraco-extensibility`, `ef-core-data`, and `umb-init` describe conventions for
*consumer* projects that install the plugin. They don't apply to this repo's own content.
Paths such as `docs/plans/`, `.claude/memory/`, or a `CLAUDE.md` mentioned inside a skill
refer to the consumer project, not this repo.

## Manifests and versioning

- The two manifests duplicate `description`, `version`, and `keywords` for the one plugin.
  Changing one means checking the other.
- Bump `version` in all three places, kept in sync: `marketplace.json` `metadata.version`,
  `marketplace.json` `plugins[0].version`, `plugin.json` `version`.
- Bump for any change to a skill, agent, or template a consumer would load. Installed
  consumers only see changes after their plugin update picks up a new version.
  - Patch: edits to an existing skill/agent/template.
  - Minor: a new skill or agent.
- Skip the bump only for files that never ship: this file, `README.md`, `QUICKSTART.md`,
  `docs/`, `scripts/`, `settings.example.json`, CI config.

## Human docs: keep them in sync

- `README.md` is a short shop window. It lists every skill once, grouped, with a one-line
  description and a link to its `SKILL.md`. Detail belongs in `docs/HOW-IT-WORKS.md` or the
  skill itself, not the README.
- `QUICKSTART.md` is install + `umb-init` + the five pipeline commands + `quick-fix`.
- `docs/HOW-IT-WORKS.md` explains the plan folder, the gate, project memory, branches and
  worktrees, and what to build on top.
- When adding, renaming, or removing a skill or agent: update the README tables and
  `docs/HOW-IT-WORKS.md`'s layout block if affected.
- When changing pipeline behavior (file ownership, when git is touched, what `umb-init`
  asks): check QUICKSTART and HOW-IT-WORKS still describe it correctly.
- Don't hard-code counts (number of skills, number of official Backoffice Skills). They drift.

## Architecture: one plan folder per feature, one file per owner

`umb-init` → `umb-explore` → `umb-design` → `umb-plan` → `umb-build-loop` each own files in
a per-feature folder (default `docs/plans/<feature-slug>/`) in the consumer project. Rules
to preserve when editing these skills:

- **Re-entrant.** Re-running a phase refines its file; it never restarts it.
- **One owner per file:**
  - `umb-explore`: `BRIEF.md`; creates the folder's `README.md` (read-order index) once and
    never recreates it.
  - `umb-design`: `ARCHITECTURE.md`, `SPEC.md`, `mockups/`, and project-wide
    `docs/mockups/starters/`.
  - `umb-plan`: `STORIES.md`, `PLAN.md`.
  - `umb-build-loop`: `BUILD-LOG.md`, `screenshots/`.
  - `describe-pr`: `PR-DESCRIPTION.md`, only when a plan folder exists.

  Outside the plan folders, `major-upgrade` owns `docs/upgrades/v<major>.md`, one file per
  CMS major upgrade, ticking its own checklist.
- **The only three cross-owner writes:**
  1. Every phase may append to `DECISION-LOG.md`.
  2. Every phase updates its own single line in `README.md` when it finishes, never
     another phase's line.
  3. `umb-build-loop` ticks `PLAN.md` checkboxes (`- [ ]` → `- [x]`), never editing task text.
- **Stop, don't guess.** A phase missing its input hands off to the owning phase instead of
  inventing the content.
- **Git boundary.** `umb-explore`/`umb-design`/`umb-plan` never touch git. `umb-build-loop`
  asks, then commits the plan folder to trunk and cuts the feature branch/worktree.

## Architecture: the builder/reviewer gate

`umb-build-loop` dispatches `agents/builder.md` per task, then `agents/reviewer.md` against
the diff, then one whole-branch review after the last task. `quick-fix` also dispatches
`reviewer`. `major-upgrade` runs the same builder/reviewer loop over its upgrade
checklist.

- `reviewer` has no `Edit`/`Write` in its frontmatter `tools:` list. This is load-bearing:
  a reviewer that can patch its own findings stops being a gate. Never add write tools to it.
- `reviewer` workflow order matters: diff → build/test → validate against docs first,
  sibling code second → impact on consumers (public API / manifest `alias` changes) → trace
  the real entry point → grep for ghost code → multi-version/provider parity → verdict.
- `issue-triager` is likewise read-only and report-only.

## Skills calling skills

A skill's behavior depends on what it's given, never on which skill started it.

- Different behavior comes from an input: an argument (`investigate-bug --unattended`), a
  file section (`BRIEF.md`'s `Repro`), or a value passed in (a repro, a drafted update).
- A skill that another skill may start drafts its tracker writes and hands them back; only
  its Hand off applies them.
- The one allowed difference is the end of the Hand off, worded the same everywhere: "If
  another skill started this one, return <result> and stop. That skill decides what runs
  next." Otherwise it offers the next step.
- Don't tell a skill who called it ("saying it was called from X"). Pass the input instead.

## Committing in this repo

Follow the `git-workflow` skill this repo ships: Conventional Commits, branch by change
size. This is a solo repo that merges via PRs to `main`. Always ask before committing
straight to `main`.

## Skill boundary discipline

Skill scope drifts one reasonable-looking edit at a time (past examples:
`dotnet-conventions` became all-Umbraco despite its name, `typescript-best-practices`
absorbed Lit content, `security-dotnet` picked up frontend XSS, two pairs of skills stated
the same rule twice).

Before adding a section to an existing skill:

1. Does it fit that skill's frontmatter `description`? If not, it belongs in another (maybe
   new) skill. Don't broaden the description to make it fit.
2. Generic language/stack discipline goes in a `*-best-practices` skill. Umbraco- or
   Lit-specific content goes in a skill named for what it covers.
3. Grep for the concept first. Don't state a rule that another skill already states.

Before renaming, splitting, or removing a skill, run `scripts/check-skill-refs.sh`. It only
catches stale references, not wrong boundaries. A false positive goes in
`scripts/skill-ref-allowlist.txt`; don't weaken the check.

After adding, renaming, splitting, or substantially changing a skill, run the repo-only
`review-skill-links` skill. It runs the check scripts, then reads for routing gaps,
conflicting advice, and duplicated rules the scripts can't see.
