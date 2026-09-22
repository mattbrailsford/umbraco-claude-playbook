# API and infrastructure extension points

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

public class AddMyPackageDashboard : PackageMigrationBase
{
    protected override void Migrate()
    {
        ImportPackage.FromEmbeddedResource<AddMyPackageDashboard>().Do();
    }
}
```

```csharp
public class MyPackageComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
        => builder.PackageMigrationPlans().Append<MyPackageMigrationPlan>();
}
```

Steps are chained and ordered by the GUID passed to `To<T>()`, the same collection-builder
shape used everywhere else in this skill. Use `PackageMigrationBase` for sync steps,
`AsyncPackageMigrationBase` for steps that need `await` (e.g. calling an async service).
`MigrationBase` still exists for non-package migrations, but a package author almost always
wants the `Package*` variants — they add helper methods for importing embedded
`package.xml`-style content/schema.

By default `IgnoreCurrentState` is `true` on a custom package migration plan, meaning the
plan's already-reached final state is ignored and it re-runs — set it to `false` once the
plan should behave like a normal migration and only run new steps. Plans run unattended at
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
it — leave the default unless the job must run on every server or a specific role. Implement
`IRecurringBackgroundJob` directly only if the class already has to inherit from something
else and can't take `RecurringBackgroundJobBase`. Inject services (`IContentService`,
`ICoreScopeProvider`, `ILogger<T>`, `IOptionsMonitor<T>`) via constructor DI as normal — the
job is resolved from the container like anything else registered through the composer.

Source: [Scheduling](https://docs.umbraco.com/umbraco-cms/extend-your-project/server-side-extensions/scheduling).

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
