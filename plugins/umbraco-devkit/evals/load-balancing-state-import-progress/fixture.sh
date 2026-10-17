#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.ProductImport
mkdir -p $d/Jobs $d/Services
cat > $d/Umbraco.Community.ProductImport.csproj <<'EOF'
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
cat > $d/Jobs/ProductImportJob.cs <<'EOF'
using Microsoft.Extensions.Logging;
using Umbraco.Cms.Infrastructure.BackgroundJobs;
using Umbraco.Community.ProductImport.Services;

namespace Umbraco.Community.ProductImport.Jobs;

public sealed class ProductImportJob(SupplierFeedClient feed, ProductWriter writer, ILogger<ProductImportJob> logger)
    : IDistributedBackgroundJob
{
    public string Name => "Umbraco.Community.ProductImport.Import";

    public TimeSpan Period => TimeSpan.FromHours(6);

    public Task ExecuteAsync() => ExecuteAsync(CancellationToken.None);

    public async Task ExecuteAsync(CancellationToken cancellationToken)
    {
        IReadOnlyList<SupplierProduct> products = await feed.GetProductsAsync(cancellationToken);
        foreach (SupplierProduct product in products)
        {
            cancellationToken.ThrowIfCancellationRequested();
            await writer.UpsertAsync(product, cancellationToken);
        }

        logger.LogInformation("Imported {Count} products", products.Count);
    }
}
EOF
cat > $d/Services/SupplierFeedClient.cs <<'EOF'
namespace Umbraco.Community.ProductImport.Services;

public sealed record SupplierProduct(string Sku, string Name, decimal Price);

public sealed class SupplierFeedClient(HttpClient http)
{
    public async Task<IReadOnlyList<SupplierProduct>> GetProductsAsync(CancellationToken cancellationToken) =>
        await System.Net.Http.Json.HttpClientJsonExtensions.GetFromJsonAsync<List<SupplierProduct>>(http, "products", cancellationToken) ?? [];
}
EOF
cat > $d/Services/ProductWriter.cs <<'EOF'
namespace Umbraco.Community.ProductImport.Services;

// Writes one product to the package's products table (EF Core). Takes ~50 ms per product.
public sealed class ProductWriter
{
    public Task UpsertAsync(SupplierProduct product, CancellationToken cancellationToken) => Task.CompletedTask;
}
EOF
