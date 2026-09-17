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

A loosely-typed, exception-happy backend fails the same way a loosely-typed frontend does: the
compiler and the type system stop catching the change you were about to break. These rules
keep the compiler doing real work, not decoration.

## Nullable reference types — enabled from day one

`<Nullable>enable</Nullable>` in every project, not just new ones. A type that can't be `null`
should never be annotated `?`; a type that genuinely can should always be. Treat a nullable
warning as a real defect, not noise to suppress:

```csharp
// Weak — every caller has to guess (or check the source) whether this can return null
public Item GetItem(Guid id) { /* ... */ }

// Strong — the signature tells the caller what to handle, the compiler enforces it
public Item? GetItem(Guid id) { /* ... */ }
public Item GetRequiredItem(Guid id) { /* throws if not found — name says so */ }
```

The null-forgiving operator (`!`) in production code is worth a second look in review — it's a
promise to the compiler you might not be able to keep. It's legitimate at a genuinely-trusted
boundary (a value just null-checked two lines up, a framework guarantee the compiler can't see)
— not as a way to silence a warning you haven't actually resolved.

## Type modeling: make invalid states unrepresentable

Prefer a type that can't express the wrong thing over a type that can, plus a runtime check.
A sealed hierarchy plus pattern matching does for C# what a discriminated union does in
TypeScript:

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

Reach for this for anything with mutually exclusive shapes (a fetch/operation state, a
workflow step, a validation outcome) instead of one class with a pile of nullable properties
and a status string.

## Error handling: exceptions for the exceptional, a result shape for the routine

A save that can fail validation, or a lookup that can legitimately not find something, is a
*routine, expected* outcome — not throwing for it is not "swallowing an error," it's modeling
the outcome so the caller is forced to handle it:

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

Roll a small `Result<T>`/`Attempt<T>`-style type once a service has more than a couple of
call sites like this, rather than hand-rolling the shape per method — Umbraco's own services
lean on this same idea (`Attempt<T>`/`Attempt<T, TStatus>`) for exactly this reason, so matching
it keeps your service layer consistent with the host rather than introducing a second
convention.

Reserve real `throw`/`try`/`catch` for genuinely exceptional, programmer-error conditions
(a violated precondition, a config value that should be impossible to be missing) — not for
routine, expected failure paths a caller is meant to branch on.

## Async: beyond naming

(Async *naming* — `[Action][Entity]Async` — is `umbraco-extensibility`'s territory; this is
about async *behavior*.)

- **Never `async void`**, except a top-level UI event handler with no other option. An
  unhandled exception in an `async void` method crashes the process instead of completing the
  `Task` with a faulted state a caller could observe.
- **Flow a `CancellationToken`** through any async chain that reaches I/O (a DB call, an HTTP
  call, a file operation) — accept one as the last parameter and pass it all the way down,
  rather than swallowing it at the top of the call stack.
- **Never `.Result` or `.Wait()` on a `Task`** in application code — sync-over-async is a
  classic deadlock and thread-pool-starvation source. If you're stuck sync-calling async code
  at a boundary you don't control, that's worth flagging, not routing around silently.
- **`ConfigureAwait(false)`**: ASP.NET Core (what Umbraco runs on) has no `SynchronizationContext`,
  so this doesn't change behavior in application/controller/service code running under it —
  don't cargo-cult it there. It still matters in code that ships as a reusable library that
  might run under a context you don't control (a classic desktop app, a different host) — add
  it there.

## LINQ: know when it runs

`IEnumerable<T>` from a LINQ query is usually **deferred** — it re-runs the query (re-hits the
database, re-iterates the source) every time it's enumerated. Materialize once with
`.ToList()`/`.ToArray()` before you enumerate it more than once, and only *after* you're done
composing the query (materializing too early against an `IQueryable<T>` forces the rest of the
query to run in memory instead of translating to SQL — see `ef-core-data` for the EF Core
side of that specifically). Prefer `.Any()` over `.Count() > 0` — it can short-circuit on the
first match instead of counting everything.

## Immutability by default

Prefer `record`/`record struct` and `init`-only properties for anything that represents data
rather than identity-with-behavior (DTOs, value objects, options/parameter objects, the
`Result<T>` shape above). A type that can't be mutated after construction can't be the source
of a bug where two callers hold the same instance and step on each other.

## Disposal: `using` declarations, not manual `Dispose()` calls

```csharp
// Prefer — disposed automatically at the end of the enclosing scope
using var connection = new SqlConnection(connectionString);

// For IAsyncDisposable
await using var stream = await OpenStreamAsync();
```

Don't hand-roll a `try`/`finally` around `Dispose()` when a `using`/`await using` declaration
expresses the same guarantee with less room for a forgotten path to skip it.

## Collections at a boundary

Accept the most general useful shape as a parameter (`IEnumerable<T>` if you only iterate
once, `IReadOnlyList<T>` if you need count/indexing) rather than a concrete `List<T>` — it
doesn't force a caller to materialize a list just to call you. Conversely, don't *return* a
mutable `List<T>`/array from a public member when callers have no legitimate reason to mutate
it; return `IReadOnlyList<T>` or `IReadOnlyCollection<T>` instead, so a caller mutating what
they got back is a compile error, not a runtime surprise for whoever else holds a reference.

## Scope note

This skill is general C#/.NET language discipline — types, nulls, async, LINQ, error shapes,
disposal, immutability. It does not cover Umbraco's own extension mechanisms (Composers,
collection builders, notification handlers, async *naming*) — that's `umbraco-extensibility`.
It does not cover EF Core/persistence specifics — that's `ef-core-data`. It does not cover
security-sensitive patterns — that's `security-dotnet`.
