# Umbraco Devkit

A Claude Code plugin for building Umbraco packages and backoffice extensions: C# / .NET
backend, EF Core persistence, Lit + UUI backoffice frontend.

- **A five-step feature pipeline.** Explore, design, plan, then build, one file per step in a
  per-feature folder.
- **A builder/reviewer gate.** Every task is built by one agent and checked by a read-only
  reviewer that runs the build and tests before anything is committed.
- **Stack knowledge.** Skills for the C#, EF Core, and Lit + UUI idioms Umbraco itself uses,
  read against the real CMS source and docs for the version you target.

**This is a foundation, not a finished house.** Drop it into a new package or add-on and
build on it as the project grows.

## Get started

Install it from inside your Umbraco project, then run:

```
/project-init     # one-time setup wizard
/feature-explore  # what are we building, and for whom?
/feature-design   # extension points, data model, API, mockups
/feature-plan     # stories and an ordered task list
/feature-build    # build, review, commit, task by task
```

Which flow fits:

| I want to... | Run |
|---|---|
| Build a new feature | `/feature-explore`, then the steps above |
| Make a small, obvious fix | `/quick-fix` |
| Find out why something is broken | `/investigate-bug` |
| Move to a new Umbraco major version | `/major-upgrade` |
| Work the issue backlog, from new to fixed | `/issue-backlog` |
| Sort through new issues | `/issue-triage` |
| Fix one triaged tracker issue | `/issue-resolve` |

You don't have to type the commands. Describe what you want ("I want to add a dashboard
that...") and the right skill picks it up.

**[QUICKSTART.md](./QUICKSTART.md)** has the install commands and a short walkthrough.

## What's included

**Pipeline:**
[`project-init`](plugins/umbraco-devkit/skills/project-init/SKILL.md),
[`feature-explore`](plugins/umbraco-devkit/skills/feature-explore/SKILL.md),
[`feature-design`](plugins/umbraco-devkit/skills/feature-design/SKILL.md),
[`feature-plan`](plugins/umbraco-devkit/skills/feature-plan/SKILL.md),
[`feature-build`](plugins/umbraco-devkit/skills/feature-build/SKILL.md), with the
[`builder`](plugins/umbraco-devkit/agents/builder.md) and
[`reviewer`](plugins/umbraco-devkit/agents/reviewer.md) agents.

**Smaller jobs:**

| Skill | What it's for |
|---|---|
| [`quick-fix`](plugins/umbraco-devkit/skills/quick-fix/SKILL.md) | A fix too small for the pipeline, still reviewed |
| [`investigate-bug`](plugins/umbraco-devkit/skills/investigate-bug/SKILL.md) | Find and prove a bug's cause, then route the fix (issue updates only on your yes) |
| [`major-upgrade`](plugins/umbraco-devkit/skills/major-upgrade/SKILL.md) | Move the package to a new Umbraco major, task by task, still reviewed |
| [`issue-triage`](plugins/umbraco-devkit/skills/issue-triage/SKILL.md) | Classify and duplicate-check tracker issues (report only), with the [`issue-triager`](plugins/umbraco-devkit/agents/issue-triager.md) agent |
| [`issue-backlog`](plugins/umbraco-devkit/skills/issue-backlog/SKILL.md) | Work open issues through triage, decisions, investigation, and fixes |
| [`issue-resolve`](plugins/umbraco-devkit/skills/issue-resolve/SKILL.md) | Route a triaged issue into `quick-fix` or the pipeline |
| [`pr-describe`](plugins/umbraco-devkit/skills/pr-describe/SKILL.md) | Write the PR description, with diagrams and screenshots |
| [`pr-review`](plugins/umbraco-devkit/skills/pr-review/SKILL.md) | Review a PR from outside the core team on a package repo |
| [`decision-review`](plugins/umbraco-devkit/skills/decision-review/SKILL.md) | Pull out the assumptions and workarounds worth a human look |
| [`git-remote`](plugins/umbraco-devkit/skills/git-remote/SKILL.md) | Set up a new GitHub repo: README, LICENSE, CONTRIBUTING |
| [`umbraco-marketplace`](plugins/umbraco-devkit/skills/umbraco-marketplace/SKILL.md) | Get a finished package listed on the Umbraco Marketplace |

**Umbraco knowledge:**

| Skill | What it covers |
|---|---|
| [`umbraco-extensibility`](plugins/umbraco-devkit/skills/umbraco-extensibility/SKILL.md) | Composers, collection builders, notification handlers |
| [`umbraco-package-conventions`](plugins/umbraco-devkit/skills/umbraco-package-conventions/SKILL.md) | Naming, visibility, safe public API changes |
| [`umbraco-backoffice-conventions`](plugins/umbraco-devkit/skills/umbraco-backoffice-conventions/SKILL.md) | Package-level frontend setup, OpenAPI clients, build order |
| [`umbraco-backoffice-ux`](plugins/umbraco-devkit/skills/umbraco-backoffice-ux/SKILL.md) | How a backoffice screen should look and behave |
| [`umbraco-performance`](plugins/umbraco-devkit/skills/umbraco-performance/SKILL.md) | Caching, tree traversal, and keeping hot paths fast |
| [`umbraco-load-balancing`](plugins/umbraco-devkit/skills/umbraco-load-balancing/SKILL.md) | Staying correct when the site runs on more than one server |
| [`ef-core-data`](plugins/umbraco-devkit/skills/ef-core-data/SKILL.md) | SQL Server + SQLite, migrations, repositories |
| [`umbraco-cms-source`](plugins/umbraco-devkit/skills/umbraco-cms-source/SKILL.md) | Read the CMS source at the version you target |
| [`umbraco-docs`](plugins/umbraco-devkit/skills/umbraco-docs/SKILL.md) | Read the official docs for the version you target |
| [`security-dotnet`](plugins/umbraco-devkit/skills/security-dotnet/SKILL.md), [`security-lit`](plugins/umbraco-devkit/skills/security-lit/SKILL.md) | Backend and frontend security checklists |

**General craft:**

| Skill | What it covers |
|---|---|
| [`dotnet-best-practices`](plugins/umbraco-devkit/skills/dotnet-best-practices/SKILL.md), [`typescript-best-practices`](plugins/umbraco-devkit/skills/typescript-best-practices/SKILL.md) | Everyday C# and TypeScript discipline |
| [`solid-principles`](plugins/umbraco-devkit/skills/solid-principles/SKILL.md), [`design-principles`](plugins/umbraco-devkit/skills/design-principles/SKILL.md), [`gof-patterns`](plugins/umbraco-devkit/skills/gof-patterns/SKILL.md) | Design principles and patterns, in C# and Lit |
| [`bdd-specs`](plugins/umbraco-devkit/skills/bdd-specs/SKILL.md), [`user-stories`](plugins/umbraco-devkit/skills/user-stories/SKILL.md) | Stories with acceptance criteria, turned into tests |
| [`git-workflow`](plugins/umbraco-devkit/skills/git-workflow/SKILL.md) | Commits, branches, and asking before touching `main` |
| [`plain-writing`](plugins/umbraco-devkit/skills/plain-writing/SKILL.md) | How every document a person reads gets written |

It works alongside the official
[Umbraco Backoffice Skills](https://github.com/umbraco/Umbraco-CMS-Backoffice-Skills)
plugin, which covers the individual backoffice extension points.

## How it works

Each feature gets one folder, `docs/plans/<feature-slug>/`. Each step owns its own file in
it, so re-running a step refines its file and never clobbers another's.
[docs/HOW-IT-WORKS.md](./docs/HOW-IT-WORKS.md) covers the folder, project memory, branches
and worktrees, and what to build on top.

## Contributing

Issues and PRs welcome. This repo follows its own
[`git-workflow`](plugins/umbraco-devkit/skills/git-workflow/SKILL.md) skill.

## License

[MIT](./LICENSE)

## Credits

Based on [Rob Conery's `claude-playbook`](https://bigmachine.io/freebies/claude-playbook)
starter template, adapted for Umbraco package and backoffice extension development.
