# Umbraco Claude Playbook

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
/umb-init          # one-time setup wizard
/umb-explore       # what are we building, and for whom?
/umb-design        # extension points, data model, API, mockups
/umb-plan          # stories and an ordered task list
/umb-build-loop    # build, review, commit, task by task
```

Which flow fits:

| I want to... | Run |
|---|---|
| Build a new feature | `/umb-explore`, then the steps above |
| Make a small, obvious fix | `/quick-fix` |
| Find out why something is broken | `/investigate-bug` |
| Move to a new Umbraco major version | `/major-upgrade` |
| Get the issue backlog ready to fix | `/issue-backlog` |
| Sort through new issues | `/issue-triage` |
| Fix one triaged tracker issue | `/issue-resolve` |

You don't have to type the commands. Describe what you want ("I want to add a dashboard
that...") and the right skill picks it up.

**[QUICKSTART.md](./QUICKSTART.md)** has the install commands and a short walkthrough.

## What's included

**Pipeline:**
[`umb-init`](plugins/umbraco-claude-playbook/skills/umb-init/SKILL.md),
[`umb-explore`](plugins/umbraco-claude-playbook/skills/umb-explore/SKILL.md),
[`umb-design`](plugins/umbraco-claude-playbook/skills/umb-design/SKILL.md),
[`umb-plan`](plugins/umbraco-claude-playbook/skills/umb-plan/SKILL.md),
[`umb-build-loop`](plugins/umbraco-claude-playbook/skills/umb-build-loop/SKILL.md), with the
[`builder`](plugins/umbraco-claude-playbook/agents/builder.md) and
[`reviewer`](plugins/umbraco-claude-playbook/agents/reviewer.md) agents.

**Smaller jobs:**

| Skill | What it's for |
|---|---|
| [`quick-fix`](plugins/umbraco-claude-playbook/skills/quick-fix/SKILL.md) | A fix too small for the pipeline, still reviewed |
| [`investigate-bug`](plugins/umbraco-claude-playbook/skills/investigate-bug/SKILL.md) | Find and prove a bug's cause, then route the fix (issue updates only on your yes) |
| [`major-upgrade`](plugins/umbraco-claude-playbook/skills/major-upgrade/SKILL.md) | Move the package to a new Umbraco major, task by task, still reviewed |
| [`issue-triage`](plugins/umbraco-claude-playbook/skills/issue-triage/SKILL.md) | Classify and duplicate-check tracker issues (report only), with the [`issue-triager`](plugins/umbraco-claude-playbook/agents/issue-triager.md) agent |
| [`issue-backlog`](plugins/umbraco-claude-playbook/skills/issue-backlog/SKILL.md) | Work open issues through triage, decisions, and investigation to ready |
| [`issue-resolve`](plugins/umbraco-claude-playbook/skills/issue-resolve/SKILL.md) | Route a triaged issue into `quick-fix` or the pipeline |
| [`describe-pr`](plugins/umbraco-claude-playbook/skills/describe-pr/SKILL.md) | Write the PR description, with diagrams and screenshots |
| [`decision-review`](plugins/umbraco-claude-playbook/skills/decision-review/SKILL.md) | Pull out the assumptions and workarounds worth a human look |
| [`git-remote`](plugins/umbraco-claude-playbook/skills/git-remote/SKILL.md) | Set up a new GitHub repo: README, LICENSE, CONTRIBUTING |
| [`umbraco-marketplace`](plugins/umbraco-claude-playbook/skills/umbraco-marketplace/SKILL.md) | Get a finished package listed on the Umbraco Marketplace |

**Umbraco knowledge:**

| Skill | What it covers |
|---|---|
| [`umbraco-extensibility`](plugins/umbraco-claude-playbook/skills/umbraco-extensibility/SKILL.md) | Composers, collection builders, notification handlers |
| [`umbraco-package-conventions`](plugins/umbraco-claude-playbook/skills/umbraco-package-conventions/SKILL.md) | Naming, visibility, safe public API changes |
| [`umbraco-backoffice-conventions`](plugins/umbraco-claude-playbook/skills/umbraco-backoffice-conventions/SKILL.md) | Package-level frontend setup, OpenAPI clients, build order |
| [`umbraco-backoffice-ux`](plugins/umbraco-claude-playbook/skills/umbraco-backoffice-ux/SKILL.md) | How a backoffice screen should look and behave |
| [`umbraco-performance`](plugins/umbraco-claude-playbook/skills/umbraco-performance/SKILL.md) | Caching, tree traversal, and keeping hot paths fast |
| [`umbraco-load-balancing`](plugins/umbraco-claude-playbook/skills/umbraco-load-balancing/SKILL.md) | Staying correct when the site runs on more than one server |
| [`ef-core-data`](plugins/umbraco-claude-playbook/skills/ef-core-data/SKILL.md) | SQL Server + SQLite, migrations, repositories |
| [`umbraco-cms-source`](plugins/umbraco-claude-playbook/skills/umbraco-cms-source/SKILL.md) | Read the CMS source at the version you target |
| [`umbraco-docs`](plugins/umbraco-claude-playbook/skills/umbraco-docs/SKILL.md) | Read the official docs for the version you target |
| [`security-dotnet`](plugins/umbraco-claude-playbook/skills/security-dotnet/SKILL.md), [`security-lit`](plugins/umbraco-claude-playbook/skills/security-lit/SKILL.md) | Backend and frontend security checklists |

**General craft:**

| Skill | What it covers |
|---|---|
| [`dotnet-best-practices`](plugins/umbraco-claude-playbook/skills/dotnet-best-practices/SKILL.md), [`typescript-best-practices`](plugins/umbraco-claude-playbook/skills/typescript-best-practices/SKILL.md) | Everyday C# and TypeScript discipline |
| [`solid-principles`](plugins/umbraco-claude-playbook/skills/solid-principles/SKILL.md), [`design-principles`](plugins/umbraco-claude-playbook/skills/design-principles/SKILL.md), [`gof-patterns`](plugins/umbraco-claude-playbook/skills/gof-patterns/SKILL.md) | Design principles and patterns, in C# and Lit |
| [`bdd-specs`](plugins/umbraco-claude-playbook/skills/bdd-specs/SKILL.md), [`user-stories`](plugins/umbraco-claude-playbook/skills/user-stories/SKILL.md) | Stories with acceptance criteria, turned into tests |
| [`git-workflow`](plugins/umbraco-claude-playbook/skills/git-workflow/SKILL.md) | Commits, branches, and asking before touching `main` |
| [`plain-writing`](plugins/umbraco-claude-playbook/skills/plain-writing/SKILL.md) | How every document a person reads gets written |

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
[`git-workflow`](plugins/umbraco-claude-playbook/skills/git-workflow/SKILL.md) skill.

## License

[MIT](./LICENSE)

## Credits

Based on [Rob Conery's `claude-playbook`](https://bigmachine.io/freebies/claude-playbook)
starter template, adapted for Umbraco package and backoffice extension development.
