#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.Shipping
mkdir -p $d/Persistence $d/Services $d/Controllers $d/Composers
cat > $d/Umbraco.Community.Shipping.csproj <<'EOF'
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
cat > $d/Persistence/ShippingDbContext.cs <<'EOF'
using Microsoft.EntityFrameworkCore;

namespace Umbraco.Community.Shipping.Persistence;

public class CurrencyRate
{
    public int Id { get; set; }
    public string Currency { get; set; } = "";
    public decimal Rate { get; set; }
}

public class ShippingZone
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public string CountryCodes { get; set; } = "";   // comma separated ISO codes
    public decimal Price { get; set; }
}

public class ShippingDbContext(DbContextOptions<ShippingDbContext> options) : DbContext(options)
{
    public DbSet<CurrencyRate> CurrencyRates => Set<CurrencyRate>();
    public DbSet<ShippingZone> Zones => Set<ShippingZone>();
}
EOF
cat > $d/Services/CurrencyRatesService.cs <<'EOF'
using Microsoft.EntityFrameworkCore;
using Umbraco.Cms.Core.Cache;
using Umbraco.Community.Shipping.Persistence;

namespace Umbraco.Community.Shipping.Services;

public sealed class CurrencyRatesService(IDbContextFactory<ShippingDbContext> dbFactory, AppCaches appCaches)
{
    private const string CacheKey = "Umbraco.Community.Shipping.CurrencyRates";

    public IReadOnlyList<CurrencyRate> GetAll() =>
        appCaches.RuntimeCache.GetCacheItem(CacheKey, () =>
        {
            using ShippingDbContext db = dbFactory.CreateDbContext();
            return (IReadOnlyList<CurrencyRate>)db.CurrencyRates.AsNoTracking().ToList();
        })!;

    public async Task SaveAsync(IEnumerable<CurrencyRate> rates)
    {
        await using ShippingDbContext db = await dbFactory.CreateDbContextAsync();
        db.CurrencyRates.RemoveRange(db.CurrencyRates);
        db.CurrencyRates.AddRange(rates);
        await db.SaveChangesAsync();
        appCaches.RuntimeCache.ClearByKey(CacheKey);
    }
}
EOF
cat > $d/Services/ShippingZonesService.cs <<'EOF'
using Microsoft.EntityFrameworkCore;
using Umbraco.Community.Shipping.Persistence;

namespace Umbraco.Community.Shipping.Services;

/// <summary>Read on every basket and checkout page to price shipping.</summary>
public sealed class ShippingZonesService(IDbContextFactory<ShippingDbContext> dbFactory)
{
    public IReadOnlyList<ShippingZone> GetAll()
    {
        using ShippingDbContext db = dbFactory.CreateDbContext();
        return db.Zones.AsNoTracking().OrderBy(z => z.Name).ToList();
    }

    public async Task SaveAsync(ShippingZone zone)
    {
        await using ShippingDbContext db = await dbFactory.CreateDbContextAsync();
        if (zone.Id == 0) db.Zones.Add(zone); else db.Zones.Update(zone);
        await db.SaveChangesAsync();
    }

    public async Task DeleteAsync(int id)
    {
        await using ShippingDbContext db = await dbFactory.CreateDbContextAsync();
        await db.Zones.Where(z => z.Id == id).ExecuteDeleteAsync();
    }
}
EOF
cat > $d/Controllers/ShippingZonesController.cs <<'EOF'
using Asp.Versioning;
using Microsoft.AspNetCore.Mvc;
using Umbraco.Cms.Api.Management.Controllers;
using Umbraco.Cms.Api.Management.Routing;
using Umbraco.Community.Shipping.Persistence;
using Umbraco.Community.Shipping.Services;

namespace Umbraco.Community.Shipping.Controllers;

[ApiVersion("1.0")]
[VersionedApiBackOfficeRoute("shipping/zones")]
[ApiExplorerSettings(GroupName = "Shipping")]
public class ShippingZonesController(ShippingZonesService zones) : ManagementApiControllerBase
{
    [HttpGet]
    public IActionResult GetAll() => Ok(zones.GetAll());

    [HttpPut]
    public async Task<IActionResult> Save(ShippingZone zone)
    {
        await zones.SaveAsync(zone);
        return Ok();
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        await zones.DeleteAsync(id);
        return Ok();
    }
}
EOF
cat > $d/Composers/ShippingComposer.cs <<'EOF'
using Microsoft.Extensions.DependencyInjection;
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Community.Shipping.Services;

namespace Umbraco.Community.Shipping.Composers;

public class ShippingComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddSingleton<CurrencyRatesService>();
        builder.Services.AddSingleton<ShippingZonesService>();
    }
}
EOF
