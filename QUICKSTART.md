# Quickstart

Two installs, then five skills. Five minutes.

```bash
# 1. The official Umbraco backoffice extension-point skills (once per machine, or once
#    per project so the whole team gets it).
claude plugin marketplace add https://github.com/umbraco/Umbraco-CMS-Backoffice-Skills.git#main --scope project
claude plugin install umbraco-cms-backoffice-skills@umbraco-backoffice-marketplace --scope project

# 2. This playbook.
cp -r umbraco-claude-playbook/.claude /path/to/your/umbraco-project/
cd /path/to/your/umbraco-project && claude
```

Then, inside Claude Code:

```
/umb-init          # once per project — CLAUDE.md, .gitignore, README stub
/umb-explore       # talk through what you're building
/umb-design        # decide which extension points, data model, API surface
/umb-plan          # slice into tasks + generate pending specs
/umb-build-loop    # build, review, commit — task by task
```

Or just describe what you want ("I want to add a dashboard that...") — these skills
auto-surface when the description matches, you don't have to invoke them by name.

Everything writes into one file per feature: `docs/plans/<feature-slug>-plan.md`. Re-run
any phase any time to refine its section; nothing gets clobbered.

**Before your first real feature:** open your project's `CLAUDE.md` and write down which
CMS major version(s) you target and which database provider(s) you support (SQL Server
only, or SQL Server + SQLite). The stack-knowledge skills (`dotnet-conventions`,
`ef-core-data`, the `reviewer` agent's parity checks) all key off that.

**Full docs:** [README.md](./README.md)
