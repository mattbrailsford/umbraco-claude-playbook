---
description: A secret masked in the editor must still never be sent back in the API response.
tags: [umbraco-security, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Umbraco package has a settings screen for a payment provider. The API key field shows as
dots in the backoffice (`type="password"`), so I think it's fine. Can you check the backend
side and tell me what, if anything, must change?

```csharp
public class ProviderSettings
{
    public Guid Id { get; set; }
    public string Name { get; set; } = "";
    public string ApiKey { get; set; } = ""; // stored as-is in our EF Core table
}

public class ProviderSettingsController : ManagementApiControllerBase
{
    private readonly MyPackageDbContext _db;
    private readonly ILogger<ProviderSettingsController> _logger;

    public ProviderSettingsController(MyPackageDbContext db, ILogger<ProviderSettingsController> logger)
    {
        _db = db;
        _logger = logger;
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetAsync(Guid id)
        => Ok(await _db.ProviderSettings.FindAsync(id));

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> SaveAsync(Guid id, ProviderSettings model)
    {
        _logger.LogInformation("Saving provider settings {@Settings}", model);
        _db.ProviderSettings.Update(model);
        await _db.SaveChangesAsync();
        return Ok(model);
    }
}
```
