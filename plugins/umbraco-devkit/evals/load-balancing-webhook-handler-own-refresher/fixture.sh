#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.Pricing
mkdir -p $d/Composers $d/Cache $d/Services $d/Persistence
cat > $d/Umbraco.Community.Pricing.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18)" />
    <PackageReference Include="Umbraco.Cms.Persistence.EFCore" Version="[17.0.0, 18)" />
  </ItemGroup>
</Project>
EOF
cat > $d/PricingOptions.cs <<'EOF'
namespace Umbraco.Community.Pricing;

/// <summary>Bound from the "Pricing" section of appsettings.json.</summary>
public class PricingOptions
{
    /// <summary>The customer's ERP endpoint for price list changes. Receives JSON POSTs.</summary>
    public string ErpWebhookUrl { get; set; } = "";
}
EOF
cat > $d/Persistence/PriceList.cs <<'EOF'
using Microsoft.EntityFrameworkCore;

namespace Umbraco.Community.Pricing.Persistence;

public class PriceList
{
    public int Id { get; set; }
    public Guid Key { get; set; }
    public string Name { get; set; } = "";
    public int Version { get; set; }
    public string PricesJson { get; set; } = "{}";
}

public class PricingDbContext(DbContextOptions<PricingDbContext> options) : DbContext(options)
{
    public DbSet<PriceList> PriceLists => Set<PriceList>();
}
EOF
cat > $d/Cache/PriceListCacheRefresher.cs <<'EOF'
using Umbraco.Cms.Core.Cache;
using Umbraco.Cms.Core.Events;
using Umbraco.Cms.Core.Serialization;
using Umbraco.Cms.Core.Sync;

namespace Umbraco.Community.Pricing.Cache;

public record PriceListPayload(Guid Key);

/// <summary>Drops the cached price list on every server when one changes.</summary>
public sealed class PriceListCacheRefresher(
    AppCaches appCaches,
    IJsonSerializer serializer,
    IEventAggregator eventAggregator,
    ICacheRefresherNotificationFactory factory)
    : PayloadCacheRefresherBase<PriceListCacheRefresherNotification, PriceListPayload>(
        appCaches, serializer, eventAggregator, factory)
{
    public static readonly Guid UniqueId = new("6b8f3d5e-2c1a-4e0b-9a7d-3f1e2b4c5d6a");

    public override Guid RefresherUniqueId => UniqueId;
    public override string Name => "Umbraco.Community.Pricing price lists";

    public override void Refresh(PriceListPayload[] payloads)
    {
        foreach (PriceListPayload payload in payloads)
        {
            AppCaches.RuntimeCache.ClearByKey(PriceListCacheKeys.For(payload.Key));
        }

        base.Refresh(payloads);
    }
}

public sealed class PriceListCacheRefresherNotification(object messageObject, MessageType messageType)
    : CacheRefresherNotification(messageObject, messageType);

public static class PriceListCacheKeys
{
    public static string For(Guid key) => $"Umbraco.Community.Pricing.PriceList.{key}";
}
EOF
cat > $d/Services/PriceListService.cs <<'EOF'
using Microsoft.EntityFrameworkCore;
using Umbraco.Cms.Core.Cache;
using Umbraco.Community.Pricing.Cache;
using Umbraco.Community.Pricing.Persistence;
using Umbraco.Extensions;

namespace Umbraco.Community.Pricing.Services;

public sealed class PriceListService(
    IDbContextFactory<PricingDbContext> dbFactory,
    AppCaches appCaches,
    DistributedCache distributedCache)
{
    public PriceList? Get(Guid key) =>
        appCaches.RuntimeCache.GetCacheItem(PriceListCacheKeys.For(key), () =>
        {
            using PricingDbContext db = dbFactory.CreateDbContext();
            return db.PriceLists.AsNoTracking().FirstOrDefault(p => p.Key == key);
        });

    public async Task SaveAsync(PriceList priceList)
    {
        await using PricingDbContext db = await dbFactory.CreateDbContextAsync();
        priceList.Version++;
        if (priceList.Id == 0) db.PriceLists.Add(priceList); else db.PriceLists.Update(priceList);
        await db.SaveChangesAsync();

        distributedCache.RefreshByPayload(
            PriceListCacheRefresher.UniqueId,
            new[] { new PriceListPayload(priceList.Key) });
    }
}
EOF
cat > $d/Composers/PricingComposer.cs <<'EOF'
using Microsoft.Extensions.DependencyInjection;
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Community.Pricing.Services;

namespace Umbraco.Community.Pricing.Composers;

public class PricingComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.Configure<PricingOptions>(builder.Config.GetSection("Pricing"));
        builder.Services.AddSingleton<PriceListService>();
    }
}
EOF
