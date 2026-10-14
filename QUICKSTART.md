# Quickstart

Two plugin installs, one setup wizard, then five steps per feature.

## 1. Install

From inside the Umbraco project you want to use this in:

```bash
# This playbook.
claude plugin marketplace add https://github.com/mattbrailsford/umbraco-claude-playbook --scope project
claude plugin install umbraco-claude-playbook@umbraco-claude-playbook --scope project

# The official Umbraco backoffice extension-point skills.
claude plugin marketplace add https://github.com/umbraco/Umbraco-CMS-Backoffice-Skills.git#main --scope project
claude plugin install umbraco-cms-backoffice-skills@umbraco-backoffice-marketplace --scope project
```

The backoffice skills follow the CMS major. `#main` is the latest major. If your project
targets an older one, swap `#main` for `#v<major>/main` (for example `#v17/main`). The
backoffice API changes between majors, so the wrong line gives confidently wrong code.

You can also run the same commands inside Claude Code as `/plugin marketplace add ...` and
`/plugin install ...`.

**Optional:** copy [`settings.example.json`](./settings.example.json) to your project's
`.claude/settings.json` and uncomment the permissions and hooks you want. It isn't installed
with the plugin, because what to allow is your call.

## 2. Set up the project

Inside Claude Code, run:

```
/umb-init
```

It's a wizard. It asks before each step: the solution (if new), `CLAUDE.md`, `.gitignore`,
demo site ports, lint, tests, and local clones of the CMS source and docs. Run it again any
time to fill gaps.

When it's done, open `CLAUDE.md` and check the **Stack** section. The CMS version(s) you
target and the database(s) you support (SQL Server only, or SQL Server + SQLite) should be
filled in, with no `TODO` left. Many skills and the reviewer's checks depend on them.

## 3. Build a feature

```
/umb-explore       # what are we building, and for whom?
/umb-design        # extension points, data model, API, mockups of new screens
/umb-plan          # stories and an ordered task list
/umb-build-loop    # build, review, commit, task by task
```

You don't have to type the commands. Describe what you want ("I want to add a dashboard
that...") and the right skill picks it up.

Everything for a feature lands in one folder: `docs/plans/<feature-slug>/`. Re-run any step
to refine its file. Nothing gets overwritten.

`/umb-build-loop` is the first step that touches git. It asks before committing the plan to
your trunk branch (usually `main`) and cutting a feature branch.

## Small fixes

For a typo, a reversed condition, or a dead `try/catch`, use `/quick-fix`. It skips the
pipeline but still gets a review, unless the change is text only. If the fix turns out
bigger than it looked, it sends you to `/umb-plan` or `/umb-explore`.

## Not sure which to use?

Just describe what you want. The right skill picks it up. Or pick one yourself:

- `/quick-fix` for a small, obvious fix.
- `/investigate-bug` for a bug nobody understands yet.
- `/major-upgrade` to move to a new Umbraco major.
- `/issue-backlog` to work through tracker issues, from new to fixed.

## More

- [README.md](./README.md): what's in the box.
- [docs/HOW-IT-WORKS.md](./docs/HOW-IT-WORKS.md): plan folders, the review gate, memory, and
  branches.
