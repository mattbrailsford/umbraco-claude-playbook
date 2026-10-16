---
description: Startup sweep that fails every Running row kills work other servers are doing. From umbraco/Umbraco.Automate#388 and umbraco/Umbraco.AI#445.
tags: [umbraco-load-balancing, should-trigger, real-bug]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

I'm about to ship this in my Umbraco 17 package. It's installed on all kinds of customer
sites. Imports run in the background and can take several minutes. If the site crashes
mid-import, the row would stay Running forever, so on startup I clean those up. Review it
before I ship. Is anything wrong?

```csharp
public class ImportRecoveryHandler
    : INotificationAsyncHandler<UmbracoApplicationStartingNotification>
{
    private readonly IDbContextFactory<ImportDbContext> _dbFactory;

    public ImportRecoveryHandler(IDbContextFactory<ImportDbContext> dbFactory)
        => _dbFactory = dbFactory;

    public async Task HandleAsync(
        UmbracoApplicationStartingNotification notification, CancellationToken ct)
    {
        await using var db = await _dbFactory.CreateDbContextAsync(ct);
        await db.ImportRuns
            .Where(r => r.Status == ImportStatus.Running || r.Status == ImportStatus.Pending)
            .ExecuteUpdateAsync(s => s
                .SetProperty(r => r.Status, ImportStatus.Failed)
                .SetProperty(r => r.Error, "Interrupted by restart"), ct);
    }
}
```
