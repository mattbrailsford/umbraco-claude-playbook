---
name: cms-upgrade
description: >-
  Moves an Umbraco package or extension to a new Umbraco CMS major version (for example 17 to
  18): finds every breaking change that actually hits the project, writes an ordered upgrade
  checklist, then works through it task by task with the builder and reviewer agents, keeping
  the build green at every commit. Owns `docs/upgrades/v<major>.md`. Use when asked to
  "upgrade to Umbraco N", "support v18", "port the package to the new major", or when a new
  CMS major ships. Not for minor or patch bumps inside one major; those are a normal
  dependency update.
user-invocable: true
argument-hint: <target CMS major, e.g. 18>
---

# cms-upgrade

A CMS major upgrade is the same features on a new base, so the `umb-explore` → `umb-design` →
`umb-plan` pipeline doesn't fit it, and it's far too big for `quick-fix`. This skill is its
own lane: it plans the upgrade from Umbraco's published breaking changes, then builds it with
the same builder → reviewer → smoke → commit gate as `umb-build-loop`.

## Scope

- IN: one hop to one target major. Dependency and target framework bumps, code changes forced
  by breaking changes or removed obsolete APIs, the frontend's `@umbraco-cms/backoffice`
  bump, and the package's own compatibility markers (version, dependency range, marketplace
  metadata, README).
- OUT: new features, refactors the upgrade doesn't force, and dropping an older major the
  project still supports. Note those in the upgrade file's "Follow-ups" section instead.
  Releasing the upgraded package is also out of scope; it's the project's own release steps.

## Argument

`$ARGUMENTS` is the target major (`18`, `v18`). If empty, ask. If the project already targets
that major, say so and stop.

## Preflight

1. **Current version.** Read the exact `Umbraco.Cms.*` version from `Directory.Packages.props`
   or the `.csproj` files, and `@umbraco-cms/backoffice` from the frontend's `package.json`
   if there is one. If projects disagree, stop and report it; fix that first.
2. **Is the hop allowed?** Use `umbraco-docs` to read the target major's breaking-changes
   page, `<major>/umbraco-cms/get-started/upgrading-and-migrating/version-specific.md`. Its
   "Preparation for Upgrade" section names the oldest version it upgrades from. If the project
   is older than that, stop: upgrade to the named version first (run this skill for that
   major), then come back.
3. **Is the target released?** List its releases:
   ```bash
   gh release list -R umbraco/Umbraco-CMS --limit 100 | grep "release-<major>\."
   ```
   If there's only a beta or RC, tell the user and ask whether to go ahead against it. An
   upgrade against a pre-release is fine for early testing; say so in the upgrade file.
4. **Other Umbraco dependencies.** For every other Umbraco package the project depends on
   (Forms, Commerce, community packages), check NuGet for a release that supports the target
   major. A missing one is a blocker: record it and ask before going on.
5. **Branch.** Read `git-workflow`'s "Umbraco packages and version tracking" section and the
   project's `CLAUDE.md` to see how it carries more than one major.
   - Branch-per-major: the new line (for example `v18/dev`) is cut from the current major's
     line. Check it doesn't already exist.
   - Single line: a short-lived branch such as `chore/upgrade-v18`.

   Confirm the working tree is clean, then **ask the user to confirm the branch name and its
   base before creating it.**

## Inventory: write `docs/upgrades/v<major>.md`

Build the list of what has to change before touching code. Only list what hits this project.
A breaking change in an area the project never uses is noise.

1. **Target framework and SDK.** Read the CMS's `TargetFramework` at the target release tag
   (`umbraco-cms-source`, `Directory.Build.props` at the repo root). If it differs from the
   project's, the upgrade includes a .NET bump, and every `Microsoft.*` and EF Core package
   moves with it. Check `global.json` too, if the project has one.
2. **Breaking changes from the docs.** Read the target major's section of the
   breaking-changes page from preflight step 2. For each entry, grep the project for the
   types, settings, URLs, or patterns it names.
3. **Breaking changes from the release notes.** Every beta, RC, and final release of the
   target `.0.0` has a "💥 Breaking Changes" section:
   ```bash
   gh release view release-<major>.0.0-beta1 -R umbraco/Umbraco-CMS --json body -q .body
   ```
   These name the PRs. Grep the project for what each PR changed or removed. When a PR's
   title isn't enough, read its diff.
4. **Obsolete APIs being removed.** On the current version, build and collect `CS0618`
   warnings. Umbraco's `[Obsolete]` messages name the major that removes the member
   ("Scheduled for removal in Umbraco 18"). Every warning naming the target major or earlier
   is a task. Warnings naming a later major are follow-ups, not blockers.
5. **Frontend.** If there's a backoffice client, compare the `exports` map in
   `src/Umbraco.Web.UI.Client/package.json` at the two release tags for every
   `@umbraco-cms/backoffice/*` path the project imports, and check which UUI major the
   target ships (`umbraco-backoffice-conventions` has the build-order and client rules). An
   import path that's gone or moved is a task.
6. **Persistence.** If the project has EF Core migrations, the .NET bump moves EF Core too.
   Note it: `ef-core-data`'s provider checks apply to the smoke.
7. **Compatibility markers.** List every place the supported CMS version is written down: the
   package's own version (per the project's choice in `git-workflow`), NuGet dependency
   ranges, `umbraco-marketplace.json`, README compatibility tables, and any CI matrix.

Write the file from `templates/UPGRADE.md`. Order the tasks so **every task ends in a green
build**:

1. Fix obsolete usages while still on the current version. Each replacement API already
   exists there, so this lands green and shrinks the bump.
2. Bump the target framework and packages, and fix what no longer compiles. This is the one
   big task. Split it by project if the solution has several.
3. Behavior changes: breaking changes that still compile but act differently (a setting's new
   default, a renamed URL, a changed notification).
4. The frontend bump and its fixes.
5. Compatibility markers.

Show the user the inventory and the ordered tasks, and wait for a yes before building. This
is the plan; a missing item here becomes a broken site later.

## Build

Commit the upgrade file on the new branch first (`docs: add upgrade plan for v<major>`). Then,
for each unchecked task, in order, follow `umb-build-loop`'s loop with these differences:

- **Build.** Give the `builder` the task text, the matching inventory entries (with their
  docs link or CMS PR), and the CMS release tag to read source at. Tell it to invoke
  `umbraco-cms-source` and `umbraco-docs` for the **target** major, not the current one.
  The same rule `umbraco-package-conventions` sets for public API applies here: if the
  upgrade forces a change to the package's own public API, proxy it with `[Obsolete]` where
  possible, and record it in the file's "Breaking changes for consumers" section when not.
- **Review.** Dispatch `reviewer` as usual, with the inventory entry as the task. No
  `#pragma warning disable` or `<NoWarn>` to silence a removed-API warning, and no skipped or
  weakened tests to get green. Either one is a `FAIL`.
- **Smoke.** Use the order in `umb-build-loop`'s "Smoke the real entry point" step. Once the
  framework bump task lands, the demo site must start on the target major and the backoffice
  must load with the package's extensions registered (no console errors from the package).
- **Tick and log.** Tick the task in the upgrade file and add its commit SHA to the "Log"
  section. A decision the inventory left open goes in the file's "Decisions" section.

## Finish

When every task is ticked:

1. Run the full test suite on every database provider the project supports.
2. **Smoke an upgrade, not just a fresh install.** Start a demo site on the current major
   with the package installed and some of its data in place. Move that site to the target
   major with the upgraded package. Check the package's migrations run and its data still
   shows. If the project has no demo site, say this was skipped in the PR.
3. Dispatch one `reviewer` in whole-feature mode over the branch diff, with the upgrade file
   as the design. Fix and re-review until `PASS`, as in `umb-build-loop`'s "Finish".
4. Open the PR with `describe-pr`. It uses its plain style, since there's no plan folder.
   Point it at the upgrade file, so the PR lists the breaking changes handled, any breaking
   changes for consumers, and the follow-ups.

## Rules

- One major per run. A two-major jump is two runs, each ending green.
- The CMS source at the target tag beats the docs, and both beat memory. Quote the tag or
  page behind every inventory entry.
- Never commit to the current major's line, or to `main`, without asking.
- If a task can't pass after repeated attempts, stop and report it with its findings. Don't
  work around a removed API by copying the CMS's old code into the package.

## Hand off

Report: current to target version, tasks done and commits, what the upgrade smoke showed,
any breaking changes for consumers, and the follow-ups. Then the PR link.
