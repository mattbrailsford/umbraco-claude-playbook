#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.EditorDigest
mkdir -p $d/Composers $d/Services
cat > $d/Umbraco.Community.EditorDigest.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18)" />
    <PackageReference Include="Umbraco.Cms.Api.Management" Version="[17.0.0, 18)" />
  </ItemGroup>
</Project>
EOF
cat > $d/Services/DigestBuilder.cs <<'EOF'
using Umbraco.Cms.Core.Models;
using Umbraco.Cms.Core.Services;

namespace Umbraco.Community.EditorDigest.Services;

/// <summary>Builds the HTML body of the "content changed in the last 24 hours" digest.</summary>
public sealed class DigestBuilder(IAuditService auditService)
{
    public async Task<string?> BuildAsync(DateTimeOffset since, CancellationToken cancellationToken)
    {
        PagedModel<IAuditItem> items = await auditService.GetItemsAsync(
            skip: 0, take: 500, sinceDate: since);
        if (items.Total == 0)
        {
            return null;
        }

        return "<ul>" + string.Concat(items.Items.Select(i => $"<li>{i.AuditType} on {i.Id} at {i.CreateDate:u}</li>")) + "</ul>";
    }
}
EOF
cat > $d/Composers/EditorDigestComposer.cs <<'EOF'
using Microsoft.Extensions.DependencyInjection;
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Community.EditorDigest.Services;

namespace Umbraco.Community.EditorDigest.Composers;

public class EditorDigestComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddSingleton<DigestBuilder>();
        builder.Services.Configure<EditorDigestOptions>(builder.Config.GetSection("EditorDigest"));
    }
}
EOF
cat > $d/EditorDigestOptions.cs <<'EOF'
namespace Umbraco.Community.EditorDigest;

public class EditorDigestOptions
{
    /// <summary>Where the digest goes, for example the editors' shared mailbox.</summary>
    public string Recipient { get; set; } = "";
}
EOF
