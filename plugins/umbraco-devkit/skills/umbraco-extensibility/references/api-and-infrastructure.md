# API and infrastructure extension points

## *Contents*

- 2\. Management API endpoint
- 3\. Health check
- 4\. Cache refresher
- 8\. Custom file system
- 9\. Package migration plan
- 10\. Recurring background job
- 11\. Custom Management API authorization policy

Rows 2, 3, 4, 8, 9, 10, 11 of the catalogue in `SKILL.md`.

## 2. Management API endpoint

Controllers derive from `ManagementApiControllerBase`, versioned and routed under
`/umbraco/management/api/v{n}`; OpenAPI is generated automatically.

```csharp
[ApiVersion("1.0")]
[VersionedApiBackOfficeRoute("my-package")]
public class MyPackageController : ManagementApiControllerBase
{
    [HttpGet]
    [MapToApiVersion("1.0")]
    public IActionResult Get() => Ok(new { message = "hello" });
}
```

Known gotcha: don't suffix the controller class name with the version number (e.g.
`MyPackageV1Controller`) — it breaks route generation.

Known gotcha: returning a `[JsonPolymorphic]` model as the whole response with `Ok(model)`
drops its `"$type"` discriminator. `Ok(object)` leaves the declared type empty, so the output
formatter serializes the runtime subtype, which carries no polymorphism metadata. Declare the
base type: return `ActionResult<TBase>`, or
`new OkObjectResult(model) { DeclaredType = typeof(TBase) }`. A polymorphic model nested as a
typed property isn't affected. A unit test calling `JsonSerializer.Serialize<TBase>` still
passes, so test the response through a `TestServer` or a real request instead.

## 3. Health check

```csharp
[HealthCheck("2c0a1f4e-0000-0000-0000-000000000000", "My Package Check",
    Description = "Verifies My Package's configuration.", Group = "My Package")]
public class MyHealthCheck : HealthCheck
{
    public override Task<IEnumerable<HealthCheckStatus>> GetStatus() { /* ... */ throw new NotImplementedException(); }

    public override HealthCheckStatus ExecuteAction(HealthCheckAction action)
        => throw new InvalidOperationException("This health check has no executable actions.");
}
```

Discovered by the attribute — surfaces automatically under Settings > Health Check. Good
fit for "is my package configured correctly" checks a site builder can self-diagnose,
instead of a support ticket. Distinct from the official Backoffice Extension Skills plugin's
`umbraco-health-check` skill, which covers a health check's *frontend* manifest
(`ManifestHealthCheck`) and context — only needed if your check wants custom backoffice UI
beyond the default status/action display.

## 4. Cache refresher

```csharp
public class MyCacheRefresher : JsonCacheRefresherBase<MyCacheRefresher, MyCacheRefresherJsonModel>
{
    public override Guid RefresherUniqueId { get; } = new("2c0a1f4e-0000-0000-0000-000000000003");
    public override string Name => "My Package Cache Refresher";
}
```

Auto-discovered; broadcasts a cache-invalidation message across load-balanced servers. One
per entity type your package owns is the normal shape once there's more than one — reach for
this the moment your package maintains its own in-memory cache that needs to stay consistent
across servers.

## 8. Custom file system

```csharp
public class MyBlobFileSystem : IFileSystem { /* Delete/Exists/GetFiles/OpenFile/... */ }
```

```csharp
builder.SetMediaFileSystem(provider => new MyBlobFileSystem(/* ... */));
```

Replaces where media/files physically live (e.g. cloud blob storage instead of local disk).

## 9. Package migration plan

This is Umbraco's own migration system — content/schema import and evolution across a
package's installs and upgrades. Don't confuse it with an EF Core migration (see
`ef-core-data`): a package can have both, for two different jobs — EF Core migrates *your
own* database tables, a `PackageMigrationPlan` migrates Umbraco content/schema (document
types, data types, content nodes) that your package ships or needs to evolve.

```csharp
public class MyPackageMigrationPlan : PackageMigrationPlan
{
    public MyPackageMigrationPlan() : base("My Package")
    {
    }

    protected override void DefinePlan()
    {
        To<AddMyPackageDashboard>(new Guid("4FD681BE-E27E-4688-922B-29EDCDCB8A49"));
    }
}

public class AddMyPackageDashboard : AsyncPackageMigrationBase
{
    public AddMyPackageDashboard(
        IPackagingService packagingService,
        IMediaService mediaService,
        MediaFileManager mediaFileManager,
        MediaUrlGeneratorCollection mediaUrlGenerators,
        IShortStringHelper shortStringHelper,
        IContentTypeBaseServiceProvider contentTypeBaseServiceProvider,
        IMigrationContext context,
        IOptions<PackageMigrationSettings> packageMigrationsSettings)
        : base(packagingService, mediaService, mediaFileManager, mediaUrlGenerators,
            shortStringHelper, contentTypeBaseServiceProvider, context, packageMigrationsSettings)
    {
    }

    protected override Task MigrateAsync()
    {
        ImportPackage.FromEmbeddedResource<AddMyPackageDashboard>().Do();
        return Task.CompletedTask;
    }
}
```

Umbraco finds every `PackageMigrationPlan` in a loaded assembly by type scanning, so the plan
needs no registration. To register it explicitly anyway, the builder is a weighted collection,
so it takes `Add<T>()`, not `Append<T>()`:

```csharp
public class MyPackageComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
        => builder.PackageMigrationPlans().Add<MyPackageMigrationPlan>();
}
```

Steps run in the order the `To<T>()` calls chain them. The value passed to each `To<T>()` is
that step's state ID, which Umbraco stores once the step has run, so never change or reuse one
after release; evolve the package by appending a new step. Use `AsyncPackageMigrationBase` for
steps: `PackageMigrationBase` (sync) is obsolete in v17 and removed in v18. `MigrationBase`
still exists for non-package migrations, but a package author almost always wants the
`Package*` variants — they add helper methods for importing embedded `package.xml`-style
content/schema.

`IgnoreCurrentState` is `false` by default on a `PackageMigrationPlan`, so only steps after
the stored state run. `AutomaticPackageMigrationPlan` sets it to `true`, re-importing its
embedded package on every run. Plans run unattended at
startup by default (`PackageMigrationsUnattended` config can disable this) or from the
Packages section in the backoffice.

**v19 note:** signatures here matched CMS 17.x at time of writing — confirm against
[Creating a Package](https://docs.umbraco.com/umbraco-cms/extend-your-project/packages/creating-a-package)
for the target version before trusting them verbatim, same as everywhere else in this skill.

## 10. Recurring background job

```csharp
public class CleanUpYourRoom : RecurringBackgroundJobBase
{
    public CleanUpYourRoom() : base(TimeSpan.FromMinutes(60))
    {
    }

    public override Task RunJobAsync(CancellationToken cancellationToken)
    {
        // your periodic work here
        return Task.CompletedTask;
    }
}
```

```csharp
public class CleanUpYourRoomComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
        => builder.Services.AddRecurringBackgroundJob<CleanUpYourRoom>();
}
```

`Period` (passed to the base constructor above) is how often it runs. `Delay` (default 3
minutes) is the wait after startup before the first run. `ServerRoles` (default `Single,
SchedulingPublisher`) restricts which server role in a load-balanced setup actually executes
it. With a load-balanced backoffice (v17+) every server is `SchedulingPublisher`, so the
default doesn't mean "one server": work that must run once uses `IDistributedBackgroundJob`
instead (below). Implement
`IRecurringBackgroundJob` directly only if the class already has to inherit from something
else and can't take `RecurringBackgroundJobBase`. From v19 the interface has no default
members: a direct implementation declares `Delay`, `IgnoredDelay`, `ServerRoles`, both change
events and `RunJobAsync(CancellationToken)` itself, and the parameterless `RunJobAsync()` is
gone. The base class supplies all of them, on every version. Inject services (`IContentService`,
`ICoreScopeProvider`, `ILogger<T>`, `IOptionsMonitor<T>`) via constructor DI as normal — the
job is resolved from the container like anything else registered through the composer.

### Work that must happen once per site

A site can run on a dedicated backoffice server with front-end `Subscriber` servers, or
(v17+) on several servers that all serve the backoffice and are all `SchedulingPublisher`.
A package can't tell which, so "the scheduling server" isn't a safe stand-in for "exactly
one server".

- **Work that must happen once per run** (send a digest, call a third-party API, write a
  shared row, clean up shared data) → `IDistributedBackgroundJob` on v17+. Umbraco tracks it
  in the database so only one server runs it at a time. Which server isn't fixed.
- **Work each server does for itself** (clear its own temp files, warm its own cache) →
  `IRecurringBackgroundJob` with `ServerRoles` set to every role.

```csharp
public class MyPackageDigestJob : IDistributedBackgroundJob
{
    public string Name => "MyPackage.Digest";
    public TimeSpan Period => TimeSpan.FromHours(1);

    public Task ExecuteAsync() => ExecuteAsync(CancellationToken.None);

    public async Task ExecuteAsync(CancellationToken cancellationToken)
    {
        // pass cancellationToken to every async call
    }
}

// In a composer
builder.Services.AddSingleton<IDistributedBackgroundJob, MyPackageDigestJob>();
```

- **Prefix `Name` with your package name.** It's the job's row in the database, shared with
  core and every other package.
- **Pass the cancellation token on.** A job that ignores it holds up the server's shutdown
  until it finishes. The `ExecuteAsync(CancellationToken)` overload arrived in 17.5; on
  earlier 17.x only `ExecuteAsync()` is called.
- **Expect a crashed run to block the next one for a while.** If a server dies mid-run, no
  other server picks the job up until its `Period` plus `DistributedJobs:MaximumExecutionTime`
  has passed.
- **A package that also supports v13** has no `IDistributedBackgroundJob` there. Keep the
  recurring job on v13 and say in its docs that it runs once only with a dedicated
  backoffice.

Source: [Scheduling](https://docs.umbraco.com/umbraco-cms/extend-your-project/server-side-extensions/scheduling),
[Distributed jobs settings](https://docs.umbraco.com/umbraco-cms/develop-with-umbraco/configuration/distributedjobssettings),
[Load balancing the backoffice](https://docs.umbraco.com/umbraco-cms/run-in-production/infrastructure-and-ops/server-setup/load-balancing/load-balancing-backoffice).

## 11. Custom Management API authorization policy

Reach for this when the built-in policies (`AuthorizationPolicies.SectionAccessContent` and
similar, applied via `[Authorize(...)]` on a row-2 controller) aren't granular enough — e.g.
access should depend on something specific to your package's own data, not just section
access. Standard ASP.NET Core authorization underneath, with one Umbraco-specific handler
base class:

```csharp
public class SectionAccessRequirement : IAuthorizationRequirement
{
    public SectionAccessRequirement(string sectionAlias) => SectionAlias = sectionAlias;
    public string SectionAlias { get; }
}

public class SectionAccessHandler : MustSatisfyRequirementAuthorizationHandler<SectionAccessRequirement>
{
    // inject IAuthorizationHelper to turn the request's principal into an IUser, then check it
}
```

```csharp
public class SectionAccessPolicyComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddSingleton<IAuthorizationHandler, SectionAccessHandler>();
        builder.Services.AddAuthorization(options =>
            options.AddPolicy("MyPackage.CustomSectionAccess", policy =>
            {
                policy.AuthenticationSchemes.Add(
                    OpenIddictValidationAspNetCoreDefaults.AuthenticationScheme);
                policy.Requirements.Add(new SectionAccessRequirement("myPackageSection"));
            }));
    }
}
```

```csharp
[Authorize("MyPackage.CustomSectionAccess")]
public class MyItemApiController : ManagementApiControllerBase { /* ... */ }
```

The requirement is a plain data container built at startup (no DI); the handler does the
actual check per-request and is where you inject whatever services you need. Don't forget
`policy.AuthenticationSchemes.Add(OpenIddictValidationAspNetCoreDefaults.AuthenticationScheme)`
— without it the policy won't authenticate against the backoffice's own auth scheme.

Source: [Access policies](https://docs.umbraco.com/umbraco-cms/extend-your-project/tutorials/creating-a-backoffice-api/access-policies).
