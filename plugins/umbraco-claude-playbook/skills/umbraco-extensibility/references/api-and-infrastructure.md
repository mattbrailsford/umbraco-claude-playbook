# API and infrastructure extension points

Rows 2, 3, 4, 8 of the catalogue in `SKILL.md`.

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
