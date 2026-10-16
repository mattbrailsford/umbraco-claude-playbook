#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/Umbraco.Community.TagCloud/Client
cat > CLAUDE.md <<'EOF'
# Umbraco.Community.TagCloud

An Umbraco 17 package (C# plus a Lit backoffice client). One version line: `main`.
EOF
cat > src/Umbraco.Community.TagCloud/Umbraco.Community.TagCloud.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework></PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.6.1, 18.0.0)" />
  </ItemGroup>
</Project>
EOF
cat > src/Umbraco.Community.TagCloud/Client/package.json <<'EOF'
{
  "name": "tag-cloud-client",
  "private": true,
  "type": "module",
  "scripts": { "build": "vite build" },
  "devDependencies": {
    "@umbraco-cms/backoffice": "16.4.0",
    "vite": "7.0.0"
  }
}
EOF
