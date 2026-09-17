# CLAUDE.md

[One-line project summary — ask if there isn't one already, or infer from an existing
README/package description.]

## Stack

- Umbraco CMS: [version(s) targeted — TODO if undetected]
- Database: [SQL Server only | SQL Server + SQLite — TODO if undetected]
- Frontend: [Lit + UUI, if a Client/ folder exists — otherwise omit this section]

## Build & test

```bash
dotnet build <solution>.sln
dotnet test <solution>.sln
```
[Fill in the real commands once detected; TODO otherwise. Add npm build/test lines only if
a frontend project exists.]

## Feature workflow

This project uses the Umbraco Claude Playbook. Feature plan docs live at:
`[the path convention settled on in the interview]`

Pipeline: `/umb-explore` → `/umb-design` → `/umb-plan` → `/umb-build-loop`.
Each owns a section of the feature's plan doc, not a whole file — see the playbook's README
for the section-ownership table.

## Conventions

[TODO — filled in as umb-explore/umb-design surface real decisions worth recording
here permanently, e.g. folder structure rules, naming conventions specific to this project.]

## Project memory

Two places a decision lives, by scope:
- **Scoped to one directory/module** → a nested `CLAUDE.md` in that directory. Claude reads
  the nearest one walking up from whatever it's editing (`reviewer` does this on every task).
- **Project-wide, but not worth permanently bloating this file** → `.claude/memory/` — one
  file per entry, indexed in `.claude/memory/MEMORY.md`. See `.claude/memory/README.md` for
  the format.
