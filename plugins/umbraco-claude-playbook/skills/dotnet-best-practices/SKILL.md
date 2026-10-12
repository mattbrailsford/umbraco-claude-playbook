---
name: dotnet-best-practices
description: >-
  General modern C#/.NET language discipline — nullable reference types, type modeling,
  async/LINQ/disposal correctness, error-handling shape, immutability. Not Umbraco-specific.
  Use when writing or reviewing any C# code, alongside `umbraco-extensibility` (which covers
  Umbraco's own extension mechanisms, not language discipline) and `ef-core-data` (persistence
  specifics). Complements `typescript-best-practices` on the frontend side.
---

# C# language discipline

## 🎯 Why: Design for Change

These rules keep the compiler and type system catching the changes you are about to break.

## Nullable reference types — enabled from day one

`<Nullable>enable</Nullable>` in every project, not just new ones. Annotate `?` only on types
that can really be `null`, and always on those. A nullable warning is a real defect, not noise
to suppress:

```csharp
// Weak — every caller has to guess (or check the source) whether this can return null
public Item GetItem(Guid id) { /* ... */ }

// Strong — the signature tells the caller what to handle, the compiler enforces it
public Item? GetItem(Guid id) { /* ... */ }
public Item GetRequiredItem(Guid id) { /* throws if not found — name says so */ }
```

Question the null-forgiving operator (`!`) in production code during review. It is fine at a
trusted boundary (a value null-checked just above, a framework guarantee the compiler can't
see). It is not a way to silence a warning you haven't resolved.

## Type modeling: make invalid states unrepresentable

Prefer a type that can't express the wrong thing over a type that can plus a runtime check.
A sealed hierarchy plus pattern matching is C#'s version of a TypeScript discriminated union:

```csharp
// Weak — every consumer has to remember to check Status before trusting the payload
public class FetchResult
{
    public string Status { get; init; } // "idle" | "loading" | "success" | "error"
    public Item? Data { get; init; }
    public string? Error { get; init; }
}

// Strong — the compiler enforces exhaustive handling via the switch expression below
public abstract record FetchResult
{
    public sealed record Idle : FetchResult;
    public sealed record Loading : FetchResult;
    public sealed record Success(Item Data) : FetchResult;
    public sealed record Failed(string Error) : FetchResult;
}

string Render(FetchResult result) => result switch
{
    FetchResult.Success s => s.Data.Name,
    FetchResult.Failed f => f.Error,
    FetchResult.Idle or FetchResult.Loading => "…",
    _ => throw new UnreachableException() // exhaustive — a new case is a compile warning here
};
```

Use this for mutually exclusive shapes (operation state, workflow step, validation outcome)
instead of one class with many nullable properties and a status string.

## Error handling: exceptions for the exceptional, a result shape for the routine

A failed validation or a lookup that finds nothing is a routine, expected outcome. Returning
it as a result is not swallowing an error; it forces the caller to handle it:

```csharp
public async Task<Result<Item>> SaveAsync(Item item)
{
    var validation = _validator.Validate(item);
    if (!validation.IsValid) return Result<Item>.Failure(validation.Errors);

    var saved = await _repository.SaveAsync(item);
    return Result<Item>.Success(saved);
}

// Usage — the caller can't accidentally skip the failure path
var result = await SaveAsync(item);
if (!result.Succeeded) { /* handle it */ }
```

Once a service has more than a couple of call sites like this, use one small
`Result<T>`/`Attempt<T>`-style type rather than a per-method shape. Umbraco's services use
`Attempt<T>`/`Attempt<T, TStatus>` for the same purpose, so matching it keeps you consistent
with the host instead of adding a second convention.

Reserve `throw`/`try`/`catch` for truly exceptional, programmer-error conditions (a violated
precondition, a config value that can't be missing), not for expected failures a caller should
branch on.

## Async: beyond naming

(Async *naming* — `[Action][Entity]Async` — is `umbraco-package-conventions`'s territory; this
is about async *behavior*.)

- **Never `async void`**, except a top-level UI event handler with no other option. Its
  unhandled exceptions crash the process instead of faulting an observable `Task`.
- **Flow a `CancellationToken`** through any async chain that reaches I/O (DB, HTTP, file).
  Accept it as the last parameter and pass it all the way down; don't drop it at the top.
- **Never `.Result` or `.Wait()` on a `Task`** in application code. Sync-over-async causes
  deadlocks and thread-pool starvation. If a boundary you don't control forces it, flag it
  rather than working around it silently.
- **`ConfigureAwait(false)`**: ASP.NET Core (what Umbraco runs on) has no
  `SynchronizationContext`, so don't add it by habit in application/controller/service code.
  Do add it in reusable library code that might run under another context (a desktop app, a
  different host).

## LINQ: know when it runs

LINQ `IEnumerable<T>` is usually **deferred**: each enumeration re-runs the query (re-hits the
database, re-iterates the source). Materialize once with `.ToList()`/`.ToArray()` before
enumerating more than once, and only *after* you finish composing the query. Materializing an
`IQueryable<T>` too early runs the rest of the query in memory instead of SQL (see
`ef-core-data` for the EF Core side). Prefer `.Any()` over `.Count() > 0`; it stops at the
first match.

## Immutability by default

Prefer `record`/`record struct` and `init`-only properties for data rather than
identity-with-behavior (DTOs, value objects, options/parameter objects, the `Result<T>` shape
above). An immutable instance can't be changed by one caller under another.

## Disposal: `using` declarations, not manual `Dispose()` calls

```csharp
// Prefer — disposed automatically at the end of the enclosing scope
using var connection = new SqlConnection(connectionString);

// For IAsyncDisposable
await using var stream = await OpenStreamAsync();
```

Don't hand-roll `try`/`finally` around `Dispose()` when a `using`/`await using` declaration
gives the same guarantee with no path to skip it.

## Collections at a boundary

Accept the most general useful parameter type (`IEnumerable<T>` if you iterate once,
`IReadOnlyList<T>` if you need count/indexing), not a concrete `List<T>`, so callers needn't
build a list just to call you. Don't *return* a mutable `List<T>`/array from a public member
when callers have no reason to mutate it; return `IReadOnlyList<T>` or
`IReadOnlyCollection<T>` so mutation is a compile error, not a runtime surprise for other
holders of the reference.

## Scope note

This skill covers general C#/.NET language discipline: types, nulls, async, LINQ, error shapes,
disposal, immutability. Not covered here:

- Umbraco extension mechanisms (Composers, collection builders, notification handlers):
  `umbraco-extensibility`.
- Async *naming*, visibility (internal by default), public-API compatibility:
  `umbraco-package-conventions`.
- EF Core/persistence specifics: `ef-core-data`.
- Security-sensitive patterns: `security-dotnet`.
