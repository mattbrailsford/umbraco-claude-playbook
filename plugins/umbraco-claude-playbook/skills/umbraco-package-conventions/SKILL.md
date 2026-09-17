---
name: umbraco-package-conventions
description: >-
  Backend package conventions for an Umbraco package that aren't about extension mechanisms
  specifically — async method naming, repository visibility, public-API backwards
  compatibility, and where extension methods live. Use when naming a service method, deciding
  a repository's accessibility, changing a public method's signature, or organizing extension
  methods. For Umbraco's own extension mechanisms (Composers, collection builders, notification
  handlers, attribute-based discovery), see `umbraco-extensibility` instead. Complements
  `dotnet-best-practices` (general C#/.NET language discipline, not Umbraco-specific) — this
  skill is Umbraco-package-specific convention, not general language discipline.
---

# Umbraco package conventions

## 🎯 Why: Design for Change

A package's own internal conventions — naming, layering, namespace organization, API stability
— don't touch its extension surface directly, but they're what makes the codebase predictable
enough that the *next* change (by you, or by a package consumer) doesn't require re-deriving
the rules from scratch each time.

## Async method naming: `[Action][Entity]Async`

| Component | Description | Examples |
|---|---|---|
| Action | Verb | `Get`, `Create`, `Update`, `Delete`, `Save`, `Find`, `List`, `Validate` |
| Entity | Noun | `Profile`, `Connection`, `Item`, `Context` |
| Async | Suffix | Always required |

Qualifiers come after the entity: `GetItemByAliasAsync`, `GetAllItemsAsync`. Existence
checks: `[Entity][Qualifier]ExistsAsync` (e.g. `ItemAliasExistsAsync`).

This is the dominant shape across real Umbraco service interfaces, though not universal —
treat it as a strong default, not a rule worth blocking a PR over on its own.

## Repository access: internal to the owning service, as a strong default

Repositories should be `internal` to the persistence assembly. Only the entity's own service
may touch its repository — controllers and other services go through the service layer:

```
Controller / other service ──▶ EntityService ──▶ EntityRepository (internal)
```

This keeps caching, validation, and business rules in one place (the service), and stops a
future refactor of the repository from becoming a breaking change for anyone but that one
service. Not a strict law — a repository can be `public` if something outside the normal
service layer (diagnostics, a health check) genuinely needs to reach it directly. Default to
`internal`; make a repository `public` only for a specific, nameable reason, not by omission.

## Public API backwards compatibility

Never break a public method's signature outright. When a new version needs new parameters,
keep the old signature and have it **proxy** to the new one, resolving the new parameter via
DI/service location if it can't be threaded through the call site:

```csharp
// Simple case — the new parameter has a sensible static default, no DI needed:
[Obsolete("Use GetItemAsync(id, options) instead. Will be removed in v19.0.0.")]
public Task<Item> GetItemAsync(Guid id) => GetItemAsync(id, ItemOptions.Default);

public Task<Item> GetItemAsync(Guid id, ItemOptions options) { /* real implementation */ }

// Harder case — the new logic genuinely needs a dependency the old call site never had,
// and the old method can't take a new constructor parameter without breaking every existing
// caller's `new MyService(...)` call. Resolve it via the static service provider instead:
[Obsolete("Use CreateAsync(item, permissionChecker) instead. Will be removed in v19.0.0.")]
public Task<Item> CreateAsync(Item item) =>
    CreateAsync(item, StaticServiceProvider.Instance.GetRequiredService<IItemPermissionChecker>());

public Task<Item> CreateAsync(Item item, IItemPermissionChecker permissionChecker) { /* real implementation */ }
```

Resolve via `StaticServiceProvider.Instance.GetRequiredService<T>()` inside the obsolete
overload, rather than duplicating the implementation, only when a static default genuinely
isn't available — a compile-time default parameter is always simpler when one exists.

Give consumers a real deprecation window — state the target version in the `[Obsolete]`
message. "Current major + 2" is a solid default; check the project's `CLAUDE.md` first and
follow whatever it actually states if it already commits to a different number.

## Extension methods

Keep them in a single, predictable namespace (e.g. `<RootNamespace>.Extensions`), not
scattered next to whatever class happened to need one first. A consumer should be able to
guess where to look. (This is C#'s *extension method* language feature — an unrelated sense of
"extension" from `umbraco-extensibility`'s Umbraco extension points; don't confuse the two.)

## Multi-version support

If the package targets more than one Umbraco CMS major at once, that's a branching and
release-versioning question, not a package-convention one — see `git-workflow`'s "Umbraco
packages and version tracking" section for branch-per-major and version-alignment guidance.
This skill doesn't restate it.
