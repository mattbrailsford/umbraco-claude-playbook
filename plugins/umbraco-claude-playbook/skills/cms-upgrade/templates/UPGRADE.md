# Upgrade to Umbraco [target major]

From `[current exact CMS version]` to `[target exact CMS version]` (tag `release-[x.y.z]`).
Branch `[branch]`, cut from `[base branch]`. [If the target is a pre-release, say so here.]

## Inventory

What the target major changes that this project actually uses. One entry per change, each
with its source (docs page, CMS PR, or release tag) and where it hits the project.

| Change | Source | Where it hits us |
|---|---|---|
| [.NET 10 → .NET 11] | [`release-19.0.0:Directory.Build.props`] | [every project] |
| [`UmbracoApiController` removed] | [version-specific.md, Umbraco 18] | [`src/Api/ProductsController.cs`] |

## Blockers

[Dependencies with no release for the target major yet, or "None".]

## Tasks

Each task ends in a green build.

- [ ] [Replace obsolete usages scheduled for removal in v[target], on the current version]
- [ ] [Bump target framework and Umbraco packages; fix compile errors]
- [ ] [Handle behavior changes]
- [ ] [Bump `@umbraco-cms/backoffice`; fix the client]
- [ ] [Update compatibility markers]

## Decisions

[Dated one-line entries for choices the inventory left open.]

## Breaking changes for consumers

[Changes to this package's own public API or manifest aliases that the upgrade forced, or
"None".]

## Follow-ups

[Things found along the way that the upgrade didn't need: obsolete APIs removed in a later
major, refactors, dropping an old major.]

## Log

[One line per task: commit SHA, what was verified.]
