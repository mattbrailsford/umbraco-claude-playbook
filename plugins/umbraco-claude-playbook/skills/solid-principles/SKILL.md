---
name: solid-principles
description: >-
  The five SOLID principles (Single Responsibility, Open/Closed, Liskov Substitution,
  Interface Segregation, Dependency Inversion), with C# examples grounded in Umbraco package
  development. Use when adding or reshaping a service, class, or interface in a C# Umbraco
  package, or when reviewing whether a design will hold up as the package grows.
---

# SOLID principles for Umbraco packages

## 🎯 Why: Design for Change

SOLID isn't a checklist to satisfy, it's five different answers to the same question: when
this changes, how big is the diff, and who else does it drag down with it? Apply whichever
principle actually shrinks the next change. Applying one that doesn't is just ceremony.

## Single Responsibility — one reason to change

A class should have one reason to change. In an Umbraco package, the classic violation is a
service that both contains business logic *and* knows how to persist itself, format itself
for the Management API, and validate its own input:

```csharp
// BAD — one class, four reasons to change
public class ItemService
{
    public Item Create(ItemRequest request) { /* validate */ /* map */ /* save to db */ /* build response DTO */ }
}

// GOOD — split by reason to change
public class ItemService
{
    public ItemService(IItemRepository repository, IItemValidator validator) { /* ... */ }
    public async Task<Item> CreateAsync(Item item, CancellationToken ct)
    {
        validator.ValidateAndThrow(item);
        return await repository.AddAsync(item, ct);
    }
}
```

The validator changes when business rules change. The repository changes when storage
changes. The service changes only when the *orchestration* between them changes. Three
independent reasons, three independent classes.

## Open/Closed — extend without modifying

A module should be open for extension, closed for modification. This is not abstract in an
Umbraco package — it's the collection-builder pattern from `umbraco-extensibility`. A package
that lets consumers register new behavior via `builder.MyPackageThings().Add<Custom>()`
never needs its own source touched to support a new case:

```csharp
// BAD — every new kind requires editing this method
public string Render(IContentNode node) =>
    node.Alias switch
    {
        "hero" => RenderHero(node),
        "gallery" => RenderGallery(node),
        // every new block type means editing this switch
        _ => throw new NotSupportedException(node.Alias)
    };

// GOOD — closed to modification, open to new registrations
public interface IBlockRenderer { bool CanRender(IContentNode node); string Render(IContentNode node); }
// new block types ship as new IBlockRenderer registrations, this class never changes again
public string Render(IContentNode node) => _renderers.First(r => r.CanRender(node)).Render(node);
```

## Liskov Substitution — a subtype must honor its supertype's contract

Anywhere the base type is expected, a derived type must work without surprising the caller.
The usual break in a provider-base-class setup is a derived class that throws where the base
promised a value, or silently does less than the interface implies:

```csharp
public abstract class ProviderBase
{
    public abstract Task<Result> ExecuteAsync(Request request, CancellationToken ct);
}

// BAD — violates the contract the base type promises
public class LimitedProvider : ProviderBase
{
    public override Task<Result> ExecuteAsync(Request request, CancellationToken ct) =>
        request.IsComplex
            ? throw new NotSupportedException() // callers coded against ProviderBase don't expect this
            : DoWork(request, ct);
}
```

If a provider genuinely can't support part of the contract, that's a signal the interface is
too wide — split it (see Interface Segregation) rather than let a subtype defect from its
promise.

## Interface Segregation — don't force a consumer to implement what it doesn't need

A fat interface forces every implementer to stub out methods it has no use for, which is
exactly the kind of ceremony that discourages people from extending your package at all:

```csharp
// BAD — a read-only provider is forced to implement Write and Delete
public interface IItemProvider
{
    Task<Item> ReadAsync(Guid id);
    Task WriteAsync(Item item);
    Task DeleteAsync(Guid id);
}

// GOOD — segregated by capability, so a provider only implements what it actually supports
public interface IItemReader { Task<Item> ReadAsync(Guid id); }
public interface IItemWriter { Task WriteAsync(Item item); Task DeleteAsync(Guid id); }
// a provider implements only the capability interfaces it actually supports
```

## Dependency Inversion — depend on abstractions, not concrete implementations

High-level modules (services, orchestration) shouldn't depend on low-level modules (a
specific database client, a specific HTTP client) directly — both depend on an interface,
resolved through DI:

```csharp
// BAD — the service is now welded to SQL Server, and untestable without one
public class ItemService
{
    private readonly SqlConnection _connection = new(connectionString);
}

// GOOD — depends on an abstraction, wired up in a Composer
public class ItemService
{
    public ItemService(IItemRepository repository) { /* ... */ }
}
```

This is also what makes supporting more than one persistence provider possible — e.g. SQL
Server and SQLite side by side, per `ef-core-data`. The service never knows which concrete
provider it's talking to.
