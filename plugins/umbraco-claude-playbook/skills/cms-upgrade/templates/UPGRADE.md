# Upgrade to Umbraco [target major]

From `[current exact CMS version]` to `[target exact CMS version]` (tag `release-[x.y.z]`).
Branch `[branch]`, cut from `[base branch]`.

**Targets CMS release:** `[release-x.y.z-rc1]`. [Updated on each refresh. While this is a
pre-release, the package's own version is a pre-release too.]

## Inventory

What the target major changes that this project actually uses. One entry per change, each
with its source (CMS PR, release tag, obsolete warning, or docs page), the CMS release it
first appeared in, and where it hits the project.

| Change | Source | Since | Where it hits us |
|---|---|---|---|
| [.NET 10 → .NET 11] | [`release-19.0.0-rc1:Directory.Build.props`] | [rc1] | [every project] |
| [`UmbracoApiController` removed] | [umbraco/Umbraco-CMS#12345] | [rc1] | [`src/Api/ProductsController.cs`] |
| [`IFooService.Get` obsolete, use `GetAsync`] | [CS0618 on `release-19.0.0-rc1`] | [rc1] | [`src/Services/Bar.cs:40`] |

## Blockers

[Dependencies with no release for the target major yet, or "None".]

## Tasks

Each task ends in a green build.

- [ ] [Replace obsolete usages flagged on the current version, before the bump]
- [ ] [Bump target framework and Umbraco packages; fix compile errors]
- [ ] [Replace APIs the target release made obsolete]
- [ ] [Handle behavior changes]
- [ ] [Bump `@umbraco-cms/backoffice`; fix the client]
- [ ] [Update compatibility markers]

## Decisions

[Dated one-line entries for choices the inventory left open.]

## Breaking changes for consumers

[Changes to this package's own public API or manifest aliases that the upgrade forced, or
"None".]

## Follow-ups

[Things found along the way that the upgrade didn't need: obsolete APIs whose replacement
isn't in every CMS version the branch builds against, refactors, dropping an old major.]

## Log

[One line per task: commit SHA, what was verified.]
