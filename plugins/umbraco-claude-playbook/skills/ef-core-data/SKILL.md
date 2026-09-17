---
name: ef-core-data
description: >-
  EF Core conventions for a persistence layer inside an Umbraco package — one entity model
  targeting both SQL Server and SQLite, product-prefixed migrations, repositories internal to
  their owning service, and testing against a real (if in-memory) database. EF Core is the
  recommended data-access approach for a new Umbraco package. Use when designing or reviewing
  a package's entities, migrations, or repositories.
---

# EF Core data for Umbraco packages

EF Core is the recommended approach for a new Umbraco package's persistence. NPoco still
appears in older code — legacy status, not a coequal choice. If you're adding to an existing
NPoco codebase, match its convention rather than introducing a second persistence technology
for one feature; for anything new, reach for EF Core and the conventions below.

## 🎯 Why: Design for Change

A package's database is shared real estate — it usually lives in the same physical database
as Umbraco core and every other installed package. The conventions below exist so a schema
change stays local to your package (never collides with someone else's tables) and so a
change to the persistence layer never becomes a breaking change for the rest of the codebase.

## One entity model, two providers

Sites run Umbraco on either SQL Server or SQLite. A package that only tested against one will
break installs on the other. Write entities and LINQ queries using provider-agnostic
constructs, and be deliberate about the handful of things that genuinely differ:

- String comparison case-sensitivity (SQLite is case-sensitive by default for `=`;
  SQL Server usually isn't, depending on collation). Don't rely on either behavior — compare
  explicitly (`.ToLower()` on both sides, or a configured case-insensitive collation) if it
  matters.
- `DateTime` vs `DateTimeOffset` handling differs subtly between providers. Pick one and be
  consistent across the whole entity model rather than mixing.
- Some SQL Server-specific functions (e.g. certain string/date functions) don't translate on
  SQLite and vice versa — if a LINQ query throws only on one provider, that's usually why.
  Test against both, not just whichever one happens to be running locally.

```csharp
// Provider-agnostic — translates cleanly on both providers
var recent = await _dbSet
    .Where(x => x.CreatedUtc >= cutoff)
    .OrderByDescending(x => x.CreatedUtc)
    .ToListAsync(cancellationToken);
```

## Migrations: generated per provider, prefixed to avoid collisions

Because a package's tables live alongside Umbraco core's and every other installed package's,
every migration name **must** be prefixed with a short, unique product/package name —
otherwise two packages can produce colliding migration history table entries or, worse,
colliding object names:

```bash
# SQL Server
dotnet ef migrations add MyPackage_InitialCreate \
  -p src/MyPackage.Persistence.SqlServer -c MyPackageDbContext --output-dir Migrations

# SQLite
dotnet ef migrations add MyPackage_InitialCreate \
  -p src/MyPackage.Persistence.Sqlite -c MyPackageDbContext --output-dir Migrations
```

Both providers share one entity model but get **separate, independently generated**
migrations — a schema change is not done until both have been regenerated and committed, not
just whichever one the author happened to test against. A reviewer should treat "SQL Server
migration added, SQLite migration missing" as an automatic finding, not a follow-up.

Every real Umbraco package that uses EF Core follows this shape with its own prefix. Pick
your own package's short prefix once and use it for every migration, forever — changing it
later just means the collision-avoidance stops working for anything migrated under the old
name.

## Repository pattern: internal to the owning service

This is the same rule `umbraco-extensibility` states for the codebase generally — this skill's
job is the EF Core-specific half of it. The `DbContext` itself, and every repository built on
it, should be `internal` to the persistence assembly:

```
Controller / other service ──▶ EntityService ──▶ EntityRepository (internal) ──▶ DbContext (internal)
```

Repository methods use short forms with the entity implicit — `GetByIdAsync`,
`GetByAliasAsync`, `GetAllAsync`, `AddAsync`, `UpdateAsync`, `DeleteAsync` — since the class
name already says what entity they're for. A `DbContext` reference (or a repository
interface) leaking into `Web`/`Api` project code is a design smell: it means a future schema
change can no longer stay local to the persistence layer.

## Testing repositories against a real database, not a fake

EF Core's `InMemory` provider does **not** generate real SQL — it's a separate, much more
forgiving execution engine that will happily pass a query your real database would reject
(an invalid `GroupBy`, an untranslatable `Where` clause, a broken migration). It hides exactly
the bugs a repository test suite exists to catch.

Prefer a real SQLite database, kept in memory for test speed but genuinely exercising SQL
translation and applied migrations:

```csharp
public sealed class EFCoreTestFixture : IDisposable
{
    private readonly SqliteConnection _connection;
    public MyPackageDbContext Context { get; }

    public EFCoreTestFixture()
    {
        // Keep the connection open for the fixture's lifetime — SQLite's in-memory
        // database only exists while at least one connection holds it open.
        _connection = new SqliteConnection("DataSource=:memory:");
        _connection.Open();

        var options = new DbContextOptionsBuilder<MyPackageDbContext>()
            .UseSqlite(_connection)
            .Options;

        Context = new MyPackageDbContext(options);
        Context.Database.Migrate(); // exercises the real migrations, not just a fresh schema
    }

    public void Dispose()
    {
        Context.Dispose();
        _connection.Dispose();
    }
}
```

Use `Context.Database.Migrate()`, not `EnsureCreated()` — the latter builds the schema
straight from the current model and skips the migrations entirely, so a broken or missing
migration would pass tests and still break real installs. Build this fixture once per
package and share it (`IClassFixture<EFCoreTestFixture>`) across every repository test rather
than reinventing it per test class.

## Schema conventions worth defaulting to

- **Surrogate keys** (`Guid` or `int` primary keys), not natural keys — a natural key (an
  alias, a slug) can need to change; a surrogate key never does.
- **Explicit `NOT NULL` foreign keys** unless the relationship is genuinely optional. An
  optional FK should be a deliberate, documented decision, not the default from forgetting a
  `.IsRequired()`.
- **Soft-delete vs. hard-delete is a per-entity decision**, not a blanket default — decide it
  in the `umb-design` phase and record the *why* (audit requirements, referential
  integrity from other entities, GDPR erasure obligations) rather than picking whichever is
  less code.
- **Keep entity classes free of Umbraco CMS framework dependencies** where possible. An
  entity that only depends on plain C# types and your own package's code stays testable in
  total isolation from a running Umbraco instance.
