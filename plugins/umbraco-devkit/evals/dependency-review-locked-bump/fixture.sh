#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/Umbraco.Community.TagCloud/Client
cat > CLAUDE.md <<'EOF'
# Umbraco.Community.TagCloud

An Umbraco 17 package (C# plus a Lit backoffice client). One version line: `main`, supporting
Umbraco 17 from 17.0.0. Changes land on `main` through PRs.
EOF
cat > Directory.Packages.props <<'EOF'
<Project>
  <PropertyGroup><ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally></PropertyGroup>
  <ItemGroup>
    <PackageVersion Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" />
  </ItemGroup>
</Project>
EOF
cat > src/Umbraco.Community.TagCloud/Umbraco.Community.TagCloud.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework></PropertyGroup>
  <ItemGroup><PackageReference Include="Umbraco.Cms.Web.Common" /></ItemGroup>
</Project>
EOF
cat > src/Umbraco.Community.TagCloud/Client/package.json <<'EOF'
{
  "name": "tag-cloud-client",
  "private": true,
  "type": "module",
  "scripts": { "build": "vite build" },
  "devDependencies": {
    "@umbraco-cms/backoffice": "17.0.0",
    "vite": "7.0.0"
  }
}
EOF
cat > BOT-PRS.json <<'EOF'
[
  {
    "number": 201,
    "title": "Bump Umbraco.Cms.Web.Common from 17.0.0 to 17.6.1",
    "author": "app/dependabot",
    "baseRefName": "main",
    "checks": "all green",
    "files": ["Directory.Packages.props"],
    "diff": "-    <PackageVersion Include=\"Umbraco.Cms.Web.Common\" Version=\"[17.0.0, 18.0.0)\" />\n+    <PackageVersion Include=\"Umbraco.Cms.Web.Common\" Version=\"[17.6.1, 18.0.0)\" />"
  },
  {
    "number": 202,
    "title": "Bump vite from 7.0.0 to 7.1.2 in /src/Umbraco.Community.TagCloud/Client",
    "author": "app/dependabot",
    "baseRefName": "main",
    "checks": "all green",
    "files": ["src/Umbraco.Community.TagCloud/Client/package.json", "src/Umbraco.Community.TagCloud/Client/package-lock.json"],
    "diff": "-    \"vite\": \"7.0.0\"\n+    \"vite\": \"7.1.2\""
  }
]
EOF
