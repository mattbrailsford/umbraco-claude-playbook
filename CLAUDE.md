# CLAUDE.md

Guidance for Claude Code when working in this repository.

This repo is a Claude Code plugin marketplace plus the one plugin it lists: a feature
pipeline, a builder/reviewer gate, and stack-knowledge skills for Umbraco package
and backoffice extension development (C#/.NET, EF Core, Lit + UUI).

New here? `README.md` says what each skill does, `docs/HOW-IT-WORKS.md` says how the skills
fit together, and "Skill families and naming" below says where a capability lives.

## Layout

```
.claude-plugin/marketplace.json                   # marketplace manifest (lists the plugin)
plugins/umbraco-devkit/
  .claude-plugin/plugin.json                      # plugin manifest
  skills/<name>/SKILL.md                          # one folder per skill (+ references/, templates/)
  agents/{builder,reviewer,issue-triager}.md      # subagents
  evals/<case>/{prompt.md,graders/}               # `claude plugin eval` cases; results/ is gitignored
settings.example.json   # copy-by-hand example for consumers; NOT installed by the plugin
scripts/                # check-*.sh + their allowlists; repo-only, not shipped
.claude/skills/review-skill-links/  # repo-only skill: cross-reference review; not shipped
docs/HOW-IT-WORKS.md    # human explainer: how skills connect, plan folder, gate, memory, branches
docs/pr-examples/       # images used in PR descriptions; not shipped
README.md               # human-facing; see "Human docs" below
```

## Skill families and naming

A skill's name says which family it belongs to. Use the family to find where a capability
lives, and to name a new skill. `README.md` lists every skill; this table lists the families.

| Family | Name | What it covers | Examples |
|---|---|---|---|
| Project | `project-<action>` | Setting up a consumer project | `project-init` |
| Feature pipeline | `feature-<step>` | One plan folder, from explore to build | `feature-explore`, `feature-build` |
| Issues | `issue-<action>` | Tracker issues, from new to fixed | `issue-triage`, `issue-resolve` |
| Pull requests | `pr-<action>` | Describing and reviewing PRs | `pr-describe`, `pr-review` |
| GitHub | `github-<action>` | The package's GitHub repo | `github-init` |
| Older jobs | kept as they are | Jobs named before the subject-first rule | `quick-fix`, `investigate-bug`, `major-upgrade`, `umbraco-marketplace` |
| Umbraco knowledge | `umbraco-<topic>` | How Umbraco does something | `umbraco-performance`, `umbraco-docs` |
| Stack knowledge | `<tech>-<topic>` | One technology, as Umbraco packages use it | `ef-core-data`, `typescript-best-practices` |
| General craft | `<lang>-best-practices`, or the topic's name | Not Umbraco-specific | `dotnet-best-practices`, `solid-principles`, `gof-patterns`, `plain-writing` |
| Agents | a role noun | Dispatched by skills, never run directly | `builder`, `reviewer`, `issue-triager` |

Naming a new skill or agent:

1. **Join a family** when the skill acts on that family's subject. Subject first, action
   second: `issue-close`, not `close-issue`.
2. **A new subject starts a new family**, even with one skill: `github-init`. A second
   skill on that subject then joins without renaming the first. The older jobs predate this
   rule; don't rename them just to fit.
3. **Name what it does for the user**, not how it works inside: `feature-build`, not
   `build-loop`.
4. **No plugin prefix** (`umb-`, `devkit-`). Claude Code already shows skills as
   `umbraco-devkit:<name>`.
5. **Don't reuse a taken name**: an Umbraco product (Workflow, Forms, Deploy, Commerce) or a
   skill in the official Backoffice Skills plugin.
6. **Folder name matches `name:`.** `scripts/check-frontmatter.sh` enforces it.
7. **Renaming a shipped skill breaks what people type.** Major version bump, and all renames
   in one PR. Follow the "Before renaming" steps under "Skill boundary discipline".

## No build, lint, or test step

Everything is Markdown plus two hand-written JSON manifests. There is no .NET code here.
Don't run `dotnet build` or apply C# conventions to this repo. Checks that do exist:

```bash
jq . .claude-plugin/marketplace.json
jq . plugins/umbraco-devkit/.claude-plugin/plugin.json
scripts/check-skill-refs.sh   # stale backtick skill references; exit 1 = needs a look
scripts/check-skill-wiring.sh # every skill in the README and referenced from elsewhere
scripts/check-version.sh      # version only in plugin.json, and bumped if shipped files changed
scripts/check-frontmatter.sh  # skill/agent headers parse, names match, descriptions fit
scripts/check-skill-callers.sh # no skill changes behavior based on which skill started it
```

Evals compare answers with and without the plugin. They make real model calls and cost
money, so run them on purpose, not as a routine check. The default judge (Haiku) misgrades
long answers such as full reviews, so judge with Sonnet:

```bash
claude plugin eval plugins/umbraco-devkit --tag <skill-name> --judge-model sonnet --no-publish
```

Ask the model to make the change, not review it. Given a short snippet to review, plain
Claude catches most mistakes, so a review prompt hides what a skill adds. Test review only
on a realistic, multi-file diff (scaffolded, like `reviewer-feature-diff`), never a
snippet. Build cases from
real, fixed bugs where possible, and tag them `real-bug`.

## This repo is not an Umbraco project

Skills like `umbraco-extensibility`, `ef-core-data`, and `project-init` describe conventions
for *consumer* projects that install the plugin. They don't apply to this repo's own content.
Paths such as `docs/plans/`, `.claude/memory/`, or a `CLAUDE.md` mentioned inside a skill
refer to the consumer project, not this repo.

## Manifests and versioning

- The two manifests duplicate `description` and `keywords` for the one plugin. Changing one
  means checking the other.
- `version` lives only in `plugin.json`. Don't add it to `marketplace.json`: Claude Code
  reads `plugin.json` first, so a second copy silently drifts.
- Bump for any change to a skill, agent, or template a consumer would load. Installed
  consumers only see changes after their plugin update picks up a new version.
  - Patch: edits to an existing skill/agent/template.
  - Minor: a new skill or agent.
  - Major: renaming or removing a skill, or any other change to what a user types.
- Skip the bump only for files that never ship: this file, `README.md`, `docs/`, `scripts/`,
  `settings.example.json`, CI config. Also skip it for `plugins/umbraco-devkit/evals/`: it
  ships inside the plugin folder, but consumers never load it.

## Human docs: keep them in sync

- `README.md` is the one entry point: what the plugin covers, install and setup, then every
  skill and agent once, with a one-line description and a link. Skills a user runs
  (`user-invocable: true`) go under "What you can do", grouped by job; the rest go under
  "What works in the background". Detail belongs in `docs/HOW-IT-WORKS.md` or the skill
  itself, not the README.
- `docs/HOW-IT-WORKS.md` explains how the skills connect (the four flows that change code,
  and what every other skill does around them), the plan folder, the gate, project memory,
  branches and worktrees, and what to build on top.
- When adding, renaming, or removing a skill or agent: update the README tables, and
  HOW-IT-WORKS's "How the skills connect" if it's a skill a user runs.
- When changing pipeline behavior (file ownership, when git is touched, what `project-init`
  asks): check the README and HOW-IT-WORKS still describe it correctly.
- Don't hard-code counts (number of skills, number of official Backoffice Skills). They drift.

## Architecture: one plan folder per feature, one file per owner

`project-init` → `feature-explore` → `feature-design` → `feature-plan` → `feature-build`
each own files in a per-feature folder (default `docs/plans/<feature-slug>/`) in the
consumer project. `feature-close` archives the folder once the work is over. Rules to
preserve when editing these skills:

- **Re-entrant.** Re-running a phase refines its file; it never restarts it.
- **One owner per file:**
  - `feature-explore`: `BRIEF.md`; creates the folder's `README.md` (read-order index) once
    and never recreates it.
  - `feature-design`: `ARCHITECTURE.md`, `SPEC.md`, `mockups/`, and project-wide
    `docs/mockups/starters/`.
  - `feature-plan`: `STORIES.md`, `PLAN.md`.
  - `feature-build`: `BUILD-LOG.md`, `screenshots/`.
  - `pr-describe`: `PR-DESCRIPTION.md`, only when a plan folder exists.
  - `feature-close`: moving a closed folder to `docs/archive/plans/<feature-slug>/`, after
    the PR is merged or the plan is dropped, and its source idea to `docs/archive/ideas/`
    once nothing in it is left.

  Ideas (`docs/ideas/`, consumer-defined) have no owner skill and no shape. `feature-explore`
  reads one as input; no skill ever edits an idea file.

  Outside the plan folders, `major-upgrade` owns `docs/upgrades/v<major>.md`, one file per
  CMS major upgrade, ticking its own checklist and archiving it to `docs/archive/upgrades/`
  once shipped.
- **The only four cross-owner writes:**
  1. Every phase may append to `DECISION-LOG.md`.
  2. Every phase updates its own single line in `README.md` when it finishes, never
     another phase's line.
  3. `feature-build` ticks `PLAN.md` checkboxes (`- [ ]` → `- [x]`), never editing task text.
  4. `feature-close` adds one `> **Status:**` line to the top of `README.md`.
- **Links that survive a move.** Code never links to repo files or memory; a comment says
  its reason itself. `CLAUDE.md` files and memory never link into plans or the archive; they
  link to each other. Plans and ideas refer to each other by name (the folder or file name),
  never by path. So archiving a plan or idea breaks nothing.
- **Stop, don't guess.** A phase missing its input hands off to the owning phase instead of
  inventing the content.
- **Git boundary.** `feature-explore`/`feature-design`/`feature-plan` never touch git.
  `feature-build` asks, then commits the plan folder to trunk and cuts the feature
  branch/worktree. `feature-close` moves closed plans on a short-lived branch and opens a
  PR for the move.

## Architecture: the builder/reviewer gate

`feature-build` dispatches `agents/builder.md` per task, then `agents/reviewer.md` against
the diff, then one whole-branch review after the last task. `quick-fix` and `change-backport` also dispatch
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
- Other mentions of a skill are fine: delegating to it, pointing at the section where it
  owns a rule, or a routing hint ("for Y, use X"). `scripts/check-skill-callers.sh` catches
  the caller wording; `review-skill-links` reads for the rest.

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
