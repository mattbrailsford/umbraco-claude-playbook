#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/Umbraco.Community.TagCloud docs
cat > src/Umbraco.Community.TagCloud/Umbraco.Community.TagCloud.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <PackageId>Umbraco.Community.TagCloud</PackageId>
    <Version>0.9.0</Version>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[13.0.0, 14.0.0)" />
  </ItemGroup>
</Project>
EOF
cat > README.md <<'EOF'
# Tag Cloud

A tag cloud for Umbraco 13. The backoffice settings screen is an AngularJS dashboard.

Not released yet: 0.9.0 is the last preview. Everything is on `main`.
EOF
