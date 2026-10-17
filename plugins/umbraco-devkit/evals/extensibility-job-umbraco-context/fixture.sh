#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.StockSync
mkdir -p $d/Services $d/Composers
cat > $d/Umbraco.Community.StockSync.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18)" />
  </ItemGroup>
</Project>
EOF
cat > $d/Services/OutOfStockFinder.cs <<'EOF'
using Umbraco.Cms.Core.Models.PublishedContent;
using Umbraco.Cms.Core.Web;
using Umbraco.Extensions;

namespace Umbraco.Community.StockSync.Services;

public sealed record OutOfStockProduct(string Name, string Url);

/// <summary>
/// Finds published products whose stock level is 0. Used by the out-of-stock report
/// in the backoffice.
/// </summary>
public sealed class OutOfStockFinder(IUmbracoContextAccessor umbracoContextAccessor)
{
    public IReadOnlyList<OutOfStockProduct> Find(Guid productsRootKey)
    {
        if (!umbracoContextAccessor.TryGetUmbracoContext(out IUmbracoContext? umbracoContext))
        {
            return [];
        }

        IPublishedContent? root = umbracoContext.Content?.GetById(productsRootKey);
        if (root is null)
        {
            return [];
        }

        return root.Children()
            .Where(p => p.ContentType.Alias == "product" && p.Value<int>("stockLevel") == 0)
            .Select(p => new OutOfStockProduct(p.Name, p.Url(mode: UrlMode.Absolute)))
            .ToList();
    }
}
EOF
cat > $d/Composers/StockSyncComposer.cs <<'EOF'
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Community.StockSync.Services;

namespace Umbraco.Community.StockSync.Composers;

public class StockSyncComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddScoped<OutOfStockFinder>();
    }
}
EOF
cat > $d/StockSyncOptions.cs <<'EOF'
namespace Umbraco.Community.StockSync;

public class StockSyncOptions
{
    public Guid ProductsRootKey { get; set; }
    public string ReportEmail { get; set; } = "";
}
EOF
