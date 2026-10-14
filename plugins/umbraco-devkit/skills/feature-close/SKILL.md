---
name: feature-close
description: >-
  Closes a feature's plan folder once the work is over: records how it ended (shipped,
  abandoned, or superseded), moves decisions that outlive the feature into project memory,
  points lasting links at those new homes, then moves the folder to the archive. Owns the
  plan's status line and its move. Use after a feature's PR is merged, on each
  version line it shipped to, or when a plan is dropped or replaced by another.
user-invocable: true
argument-hint: [feature slug or plan folder path, one or more, optional]
---

# feature-close

Keep the plans folder to work that's still live. A closed plan moves out, so an active plan is
easy to find, and Claude stops reading an old design as if it were the current one. What the
plan decided that still matters moves somewhere that lasts first, so nothing points into the
archive.

## Where this writes

The project's archive folder, set next to the plan-folder path in `CLAUDE.md`'s "Feature
workflow" section (default `docs/archive/`, one sub-folder per kind of plan). A feature's
plan folder moves from `docs/plans/<feature-slug>/` to `docs/archive/plans/<feature-slug>/`.

- **Owns:** the move, and one `> **Status:**` line at the top of the plan folder's
  `README.md`. That line is the only edit this skill makes inside the plan folder.
- **Writes outside it:** `.claude/memory/` entries and nested `CLAUDE.md` files for what the
  plan decided, and link fixes in lasting files (step 3).
- **Never** edits any other file in the plan folder. They record what happened at the time;
  rewriting them after the fact loses that.

`major-upgrade` archives its own upgrade checklist with the same steps (see its "Archive"
section).

## Scope

- IN: one or more closed plan folders on one version line.
- OUT: plans still in progress, or with a PR still open. Reference docs, memory, and logs:
  those describe how things are now, so they get updated, never archived.

## Preflight

1. **Resolve the plan folders.** Use the argument; else list the folders under the plans
   path and ask which are closed. Don't guess from age or file contents.
2. **Check the working tree is clean** and you're on the version line's trunk branch (see
   `CLAUDE.md`'s "Feature workflow" section). If not, stop and report.
3. **Find how each plan ended.** Look for its PR by the feature's branch name:
   ```bash
   gh pr list --head <branch> --state all --json number,state,baseRefName,mergedAt,url
   ```
   - **Merged into this line's trunk:** shipped. Note the PR and the merge date.
   - **Open:** stop. The plan isn't closed yet.
   - **Closed without merging, or no PR at all:** ask whether it was abandoned (and why, in
     one line) or superseded (and by which plan).

   A feature that ships to more than one version line (`v17/dev` and `v18/dev`) is archived
   on each line by its own run, once that line's PR is merged. Each line's archive is its
   own.

## Close each plan

Show the user what each step will change and wait for a yes before step 4.

1. **Write the status line.** Add it at the top of the plan folder's `README.md`, under the
   title:

   ```md
   > **Status:** Shipped <date>, #<PR> into `<trunk>`. <one line: anything left undone>
   > **Status:** Abandoned <date>. <one line: why>
   > **Status:** Superseded <date> by `<other-slug>`. <one line: what carried over>
   ```

   No `README.md`? Create one with the title, the status line, and a plain list of the files
   in the folder. Never copy the status line into the other files.

2. **Save what outlives the feature.** Read `DECISION-LOG.md`, `ARCHITECTURE.md`, and
   `SPEC.md`. For each decision or explanation that future work needs, pick its lasting home
   (as `feature-explore` and `feature-design` do when they record a decision):
   - A rule for one directory or module: that directory's `CLAUDE.md`.
   - A project-wide decision: `.claude/memory/`, type `decision`. See
     `.claude/memory/README.md` for the format.
   - A longer "how this works": the project's own reference docs, if it keeps any. If it
     doesn't, keep only the rule and its reason, in one of the two homes above.

   Skip what a lasting file already says. Most of a plan is about how the work got done, and
   that stays in the archive. An abandoned plan usually has one thing worth saving: why it
   was dropped, so it isn't tried again blind.

3. **Point lasting links at the new homes.** Search the repo, outside the plans and archive
   folders, for links into this plan folder:
   ```bash
   git grep -n "<plans-path>/<feature-slug>" -- ':!<plans-path>' ':!<archive-path>'
   ```
   Each hit is in a lasting file (code, a `CLAUDE.md`, memory, reference docs) and breaks the
   rule in `CLAUDE.md`'s "Plans and the archive" section. Point it at the home from step 2.
   If nothing in step 2 fits, step 2 missed something: go back. Links from other live plan
   folders just change to the archive path.

4. **Move the folder.** `git mv <plans-path>/<feature-slug> <archive-path>/plans/<feature-slug>`.
   Links inside the folder are relative, so they still work.

5. **Commit and open a PR.** On a short-lived branch off this line's trunk, named per
   `git-workflow` (for example `docs/archive-plans` or `v18/docs/archive-plans`). One commit
   for the whole run: `docs: archive <feature-slug> plan`, or `docs: archive shipped plans`
   when there are several. Then invoke `pr-describe` to open the PR.

## Rules

- Never archive a plan whose PR is still open on this line.
- Never edit a plan's files beyond its `README.md` status line.
- Step 3 is what makes the move safe. The link rule itself lives in `CLAUDE.md`'s "Plans
  and the archive" section.

## Hand off

List each plan archived, how it ended, what was saved where, and the links repointed. Then
the PR link.
