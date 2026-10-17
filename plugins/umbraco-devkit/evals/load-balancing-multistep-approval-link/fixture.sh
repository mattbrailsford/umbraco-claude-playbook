#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.Approvals
mkdir -p $d/Services
cat > $d/Umbraco.Community.Approvals.csproj <<'EOF'
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
cat > $d/Services/ApprovalPublisher.cs <<'EOF'
using Umbraco.Cms.Core;
using Umbraco.Cms.Core.Services;

namespace Umbraco.Community.Approvals.Services;

public sealed class ApprovalPublisher(IContentPublishingService publishingService)
{
    public async Task<bool> PublishAsync(Guid documentKey)
    {
        var result = await publishingService.PublishAsync(
            documentKey, [new() { Culture = "*" }], Constants.Security.SuperUserKey);
        return result.Success;
    }
}
EOF
cat > $d/ApprovalOptions.cs <<'EOF'
namespace Umbraco.Community.Approvals;

public class ApprovalOptions
{
    public string FromAddress { get; set; } = "";
}
EOF
