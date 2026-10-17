#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.StockSync
mkdir -p $d/Services
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
cat > $d/Services/ProductDocumentService.cs <<'EOF'
using Umbraco.Cms.Core;
using Umbraco.Cms.Core.Models;
using Umbraco.Cms.Core.Services;
using Umbraco.Cms.Core.Services.OperationStatus;

namespace Umbraco.Community.StockSync.Services;

/// <summary>
/// Writes stock data from the warehouse feed onto "product" documents.
/// </summary>
/// <remarks>
/// The "product" document type is invariant (no cultures) and has these properties:
/// <list type="bullet">
///   <item><c>title</c>: Textstring</item>
///   <item><c>stockLevel</c>: Numeric</item>
///   <item><c>featured</c>: Toggle</item>
///   <item><c>colour</c>: Dropdown (single choice)</item>
///   <item><c>relatedProducts</c>: Multinode Treepicker (documents)</item>
/// </remarks>
internal sealed class ProductDocumentService(IContentEditingService contentEditingService)
{
    // Writes go through IContentEditingService so validation and notifications run the
    // same way as a save from the backoffice.

    /// <summary>
    /// Sets the product's stock level and saves it (no publish). Returns false if the
    /// document doesn't exist or the save fails.
    /// </summary>
    public async Task<bool> SetStockLevelAsync(Guid productKey, int stockLevel)
    {
        throw new NotImplementedException();
    }
}
EOF
