#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.Importer
mkdir -p $d/Persistence $d/Imports $d/Controllers $d/Composers
cat > $d/Umbraco.Community.Importer.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18)" />
    <PackageReference Include="Umbraco.Cms.Api.Management" Version="[17.0.0, 18)" />
    <PackageReference Include="Umbraco.Cms.Persistence.EFCore" Version="[17.0.0, 18)" />
  </ItemGroup>
</Project>
EOF
cat > $d/Persistence/ImportRun.cs <<'EOF'
namespace Umbraco.Community.Importer.Persistence;

public enum ImportStatus
{
    Pending,
    Running,
    Done,
    Failed,
}

public class ImportRun
{
    public int Id { get; set; }
    public string SourceUrl { get; set; } = "";
    public ImportStatus Status { get; set; }
    public string? Error { get; set; }
    public DateTime CreatedUtc { get; set; }
    public DateTime? StartedUtc { get; set; }
    public DateTime? FinishedUtc { get; set; }
}
EOF
cat > $d/Persistence/ImportDbContext.cs <<'EOF'
using Microsoft.EntityFrameworkCore;

namespace Umbraco.Community.Importer.Persistence;

public class ImportDbContext(DbContextOptions<ImportDbContext> options) : DbContext(options)
{
    public DbSet<ImportRun> ImportRuns => Set<ImportRun>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<ImportRun>(b =>
        {
            b.ToTable("importerImportRun");
            b.HasIndex(r => r.Status);
        });
    }
}
EOF
cat > $d/Imports/ImportWorker.cs <<'EOF'
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Umbraco.Community.Importer.Persistence;

namespace Umbraco.Community.Importer.Imports;

/// <summary>
/// Claims Pending import runs and processes them. Imports can take several minutes.
/// </summary>
internal sealed class ImportWorker(
    IDbContextFactory<ImportDbContext> dbFactory,
    ImportProcessor processor,
    ILogger<ImportWorker> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            int? runId = await TryClaimNextAsync(stoppingToken);
            if (runId is null)
            {
                await Task.Delay(TimeSpan.FromSeconds(15), stoppingToken);
                continue;
            }

            await RunAsync(runId.Value, stoppingToken);
        }
    }

    private async Task<int?> TryClaimNextAsync(CancellationToken ct)
    {
        await using ImportDbContext db = await dbFactory.CreateDbContextAsync(ct);
        int? id = await db.ImportRuns
            .Where(r => r.Status == ImportStatus.Pending)
            .OrderBy(r => r.CreatedUtc)
            .Select(r => (int?)r.Id)
            .FirstOrDefaultAsync(ct);
        if (id is null)
        {
            return null;
        }

        // Only one worker wins the claim.
        int claimed = await db.ImportRuns
            .Where(r => r.Id == id && r.Status == ImportStatus.Pending)
            .ExecuteUpdateAsync(s => s
                .SetProperty(r => r.Status, ImportStatus.Running)
                .SetProperty(r => r.StartedUtc, DateTime.UtcNow), ct);
        return claimed == 1 ? id : null;
    }

    private async Task RunAsync(int runId, CancellationToken ct)
    {
        ImportStatus result = ImportStatus.Done;
        string? error = null;
        try
        {
            await processor.ProcessAsync(runId, ct);
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            logger.LogError(ex, "Import {RunId} failed", runId);
            result = ImportStatus.Failed;
            error = ex.Message;
        }

        await using ImportDbContext db = await dbFactory.CreateDbContextAsync(CancellationToken.None);
        await db.ImportRuns
            .Where(r => r.Id == runId)
            .ExecuteUpdateAsync(s => s
                .SetProperty(r => r.Status, result)
                .SetProperty(r => r.Error, error)
                .SetProperty(r => r.FinishedUtc, DateTime.UtcNow));
    }
}
EOF
cat > $d/Imports/ImportProcessor.cs <<'EOF'
namespace Umbraco.Community.Importer.Imports;

/// <summary>Downloads the feed for a run and creates or updates content. Takes minutes.</summary>
internal sealed class ImportProcessor
{
    public Task ProcessAsync(int runId, CancellationToken ct)
    {
        // Real implementation omitted: pages through the feed and saves content in batches.
        return Task.Delay(TimeSpan.FromMinutes(5), ct);
    }
}
EOF
cat > $d/Controllers/ImportRunsController.cs <<'EOF'
using Asp.Versioning;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Umbraco.Cms.Api.Management.Controllers;
using Umbraco.Cms.Api.Management.Routing;
using Umbraco.Community.Importer.Persistence;

namespace Umbraco.Community.Importer.Controllers;

[ApiVersion("1.0")]
[VersionedApiBackOfficeRoute("importer/runs")]
[ApiExplorerSettings(GroupName = "Importer")]
public class ImportRunsController(IDbContextFactory<ImportDbContext> dbFactory) : ManagementApiControllerBase
{
    [HttpPost("{id:int}/retry")]
    public async Task<IActionResult> Retry(int id)
    {
        await using ImportDbContext db = await dbFactory.CreateDbContextAsync();
        // Only failed runs can be retried; a Running run is still in progress.
        int updated = await db.ImportRuns
            .Where(r => r.Id == id && r.Status == ImportStatus.Failed)
            .ExecuteUpdateAsync(s => s
                .SetProperty(r => r.Status, ImportStatus.Pending)
                .SetProperty(r => r.Error, (string?)null));
        return updated == 1 ? Ok() : Conflict();
    }
}
EOF
cat > $d/Composers/ImporterComposer.cs <<'EOF'
using Microsoft.Extensions.DependencyInjection;
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Community.Importer.Imports;
using Umbraco.Community.Importer.Persistence;
using Umbraco.Extensions;

namespace Umbraco.Community.Importer.Composers;

public class ImporterComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddUmbracoDbContext<ImportDbContext>((options, connectionString, providerName, serviceProvider) =>
            options.UseUmbracoDatabaseProvider(serviceProvider));
        builder.Services.AddSingleton<ImportProcessor>();
        builder.Services.AddHostedService<ImportWorker>();
    }
}
EOF
