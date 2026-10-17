#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.Announcements
mkdir -p $d/Persistence $d/Services $d/Controllers $d/Composers $d/ViewComponents
cat > $d/Umbraco.Community.Announcements.csproj <<'EOF'
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
cat > $d/Persistence/AnnouncementSettings.cs <<'EOF'
using Microsoft.EntityFrameworkCore;

namespace Umbraco.Community.Announcements.Persistence;

public class AnnouncementSettings
{
    public int Id { get; set; }
    public bool Enabled { get; set; }
    public string Message { get; set; } = "";
    public string Style { get; set; } = "info";
}

public class AnnouncementsDbContext(DbContextOptions<AnnouncementsDbContext> options) : DbContext(options)
{
    public DbSet<AnnouncementSettings> Settings => Set<AnnouncementSettings>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
        => modelBuilder.Entity<AnnouncementSettings>().ToTable("announcementsSettings");
}
EOF
cat > $d/Services/AnnouncementSettingsService.cs <<'EOF'
using Microsoft.EntityFrameworkCore;
using Umbraco.Community.Announcements.Persistence;

namespace Umbraco.Community.Announcements.Services;

/// <summary>The site-wide announcement banner settings. There is only ever one row.</summary>
public sealed class AnnouncementSettingsService(IDbContextFactory<AnnouncementsDbContext> dbFactory)
{
    public AnnouncementSettings Get()
    {
        using AnnouncementsDbContext db = dbFactory.CreateDbContext();
        return db.Settings.AsNoTracking().FirstOrDefault() ?? new AnnouncementSettings();
    }

    public async Task SaveAsync(AnnouncementSettings settings)
    {
        await using AnnouncementsDbContext db = await dbFactory.CreateDbContextAsync();
        AnnouncementSettings? row = await db.Settings.FirstOrDefaultAsync();
        if (row is null)
        {
            db.Settings.Add(settings);
        }
        else
        {
            row.Enabled = settings.Enabled;
            row.Message = settings.Message;
            row.Style = settings.Style;
        }

        await db.SaveChangesAsync();
    }
}
EOF
cat > $d/ViewComponents/AnnouncementBannerViewComponent.cs <<'EOF'
using Microsoft.AspNetCore.Mvc;
using Umbraco.Community.Announcements.Services;

namespace Umbraco.Community.Announcements.ViewComponents;

/// <summary>Rendered in the site layout on every page.</summary>
public class AnnouncementBannerViewComponent(AnnouncementSettingsService settingsService) : ViewComponent
{
    public IViewComponentResult Invoke()
    {
        var settings = settingsService.Get();
        return settings.Enabled ? View(settings) : Content(string.Empty);
    }
}
EOF
cat > $d/Controllers/AnnouncementSettingsController.cs <<'EOF'
using Asp.Versioning;
using Microsoft.AspNetCore.Mvc;
using Umbraco.Cms.Api.Management.Controllers;
using Umbraco.Cms.Api.Management.Routing;
using Umbraco.Community.Announcements.Persistence;
using Umbraco.Community.Announcements.Services;

namespace Umbraco.Community.Announcements.Controllers;

[ApiVersion("1.0")]
[VersionedApiBackOfficeRoute("announcements/settings")]
[ApiExplorerSettings(GroupName = "Announcements")]
public class AnnouncementSettingsController(AnnouncementSettingsService settingsService) : ManagementApiControllerBase
{
    [HttpGet]
    public IActionResult Get() => Ok(settingsService.Get());

    [HttpPut]
    public async Task<IActionResult> Save(AnnouncementSettings settings)
    {
        await settingsService.SaveAsync(settings);
        return Ok();
    }
}
EOF
cat > $d/Composers/AnnouncementsComposer.cs <<'EOF'
using Microsoft.Extensions.DependencyInjection;
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Community.Announcements.Persistence;
using Umbraco.Community.Announcements.Services;
using Umbraco.Extensions;

namespace Umbraco.Community.Announcements.Composers;

public class AnnouncementsComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddUmbracoDbContext<AnnouncementsDbContext>((options, connectionString, providerName, serviceProvider) =>
            options.UseUmbracoDatabaseProvider(serviceProvider));
        builder.Services.AddSingleton<AnnouncementSettingsService>();
    }
}
EOF
