#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.ReviewDigest
mkdir -p $d/Services
cat > $d/Umbraco.Community.ReviewDigest.csproj <<'EOF'
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
cat > $d/Services/ReviewDigestBuilder.cs <<'EOF'
using Umbraco.Cms.Core.Models;
using Umbraco.Cms.Core.Services;

namespace Umbraco.Community.ReviewDigest.Services;

public sealed record PendingReview(Guid Key, string Name, DateTime UpdatedUtc);

public sealed class ReviewDigestBuilder(IContentService contentService)
{
    // Pages saved but not yet published.
    public IReadOnlyList<PendingReview> Build()
    {
        IEnumerable<IContent> roots = contentService.GetRootContent();
        var pending = new List<PendingReview>();
        foreach (IContent root in roots)
        {
            foreach (IContent c in contentService.GetPagedDescendants(root.Id, 0, 500, out _).Prepend(root))
            {
                if (c.Edited)
                {
                    pending.Add(new PendingReview(c.Key, c.Name ?? "", c.UpdateDate.ToUniversalTime()));
                }
            }
        }

        return pending;
    }
}
EOF
cat > $d/ReviewDigestOptions.cs <<'EOF'
namespace Umbraco.Community.ReviewDigest;

public class ReviewDigestOptions
{
    public string To { get; set; } = "";
}
EOF
